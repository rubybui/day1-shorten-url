class UrlsController < ApplicationController
    def new
      @url = Url.new
    end
  
    def create
      input_url = params[:url][:original_url].strip
  
      @url = Url.find_by(original_url: input_url)
      if @url
        redirect_to redirect_path(@url.short_url)
      else
        @url = Url.new(url_params)
        @url.original_url = input_url
  
        if params[:url][:short_url].present?
          @url.short_url = params[:url][:short_url]
        end
  
        if @url.save
          redirect_to redirect_path(@url.short_url)
        else
          render :new, status: :unprocessable_entity
        end
      end
    end
  
    def redirect
        @url = Url.find_by(short_url: params[:short_url])
        if @url
          redirect_to @url.original_url, allow_other_host: true
        else
          render plain: "URL not found", status: :not_found
        end
      end      
  
    private
  
    def url_params
      params.require(:url).permit(:original_url, :short_url)
    end
  end
  