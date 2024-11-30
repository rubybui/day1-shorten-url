class Url < ApplicationRecord
    before_validation :generate_short_url, on: :create, unless: -> { short_url.present? }
  
    validates :original_url, presence: true, uniqueness: true
    validates :short_url, uniqueness: true, format: { with: /\A[a-zA-Z0-9]+\z/, message: 'only allows alphanumeric characters' }
  
    private
  
    def generate_short_url
      self.short_url = generate_code_from_url(original_url)
      if self.short_url.nil?
        errors.add(:base, "Unable to generate a unique short URL. Please try again.")
      end
    end
  
    def generate_code_from_url(url)
      max_attempts = 3
      collision_count = 0
  
      max_attempts.times do
        hash_input = url + collision_count.to_s
        hash = Digest::MD5.hexdigest(hash_input)
        hash_int = hash.to_i(16)
        base62 = base62_encode(hash_int)
  
        short_code_length = 6
        short_code = base62[0, short_code_length]
  
        # Return the short code if it's unique
        # Note: Different long URLs might produce similar short URLs due to:
        # - Hash collisions from truncating hashes (e.g., using only the first 6 characters).
        # - Limited short code length (62^6 combinations for 6-character Base62 codes).
        # - Similar input URLs leading to similar hash outputs after truncation.
        # - Loss of uniqueness when truncating hash outputs reduces distribution.
        # - Deterministic algorithms without randomness can cause similar inputs to yield similar outputs.

        unless Url.exists?(short_url: short_code)
          return short_code
        end
  
        collision_count += 1
      end
  
      # Return nil if unable to generate a unique short code after max_attempts
      nil
    end
  
    def base62_encode(number)
      return '0' if number == 0
      chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
      base = chars.length
      encoded = ''
      while number > 0
        encoded.prepend(chars[number % base])
        number /= base
      end
      encoded
    end
  end