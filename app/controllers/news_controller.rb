class NewsController < ApplicationController
  ORIGINAL_URL="https://news.ycombinator.com"

  before_action :load_current_page, :load_next_page, :load_previous_page, :build_url, :load_news, :load_total_page, only: :index
  before_action :get_url, :get_title, :build_bonus_info, only: :show
  
  def index
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @news = ParsingService.new(@url, ORIGINAL_URL).proccess_detail
    if @news.blank?
      flash[:danger] = "Website does not exist"
      redirect_to news_index_path
    end  
  end

  private

  def load_news
    @news = if File.exist?("public/#{@current_page}.json")
      file = File.read("public/#{@current_page}.json")
      JSON.parse(file).to_a
    else 
      []
    end
  end

  def load_current_page
    @current_page = params[:page].present? ? params[:page].to_i : 1 
  end 

  def load_next_page
    @next_page = @current_page + 1
  end 

  def load_previous_page
    @previous_page = @current_page - 1
  end 

  def build_url
    params_url = "?p=#{@current_page}" if @current_page &&  @current_page > 1
    @url = "#{ORIGINAL_URL}/best#{params_url}"
  end

  def get_url
    @url = params[:url]
  end

  def get_title
    @title = params[:title]
  end

  def load_total_page
    @total_page = if File.exist?("public/info.json") 
      file = File.read("public/info.json")
      JSON.parse(file)["page"]&.to_i
    end
  end

  def build_bonus_info
    @bonus_info = {
      last_score: params[:last_score],
      user: params[:user],
      comment_number: params[:comment_number],
    }
  end
end
