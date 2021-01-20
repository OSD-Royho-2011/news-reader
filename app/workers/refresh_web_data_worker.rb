class RefreshWebDataWorker
  include Sidekiq::Worker
  ORIGINAL_URL="https://news.ycombinator.com"

  def perform
    scraping
  end

  private

    def scraping
      url = ORIGINAL_URL + "/best"
      page = 1
      content = nil
      begin
        puts url
        content = ParsingService.new(url, ORIGINAL_URL).proccess_list
        refresh_file(content, page) if content.present?
        page += 1
        url = build_url(page)
      end while content.present?
      
      info = {
        page: (page - 2)
      }
      refresh_file info, "info"
    end

    def build_url page
      "#{ORIGINAL_URL}/best?p=#{page}"
    end

    def refresh_file data, page
      directory = "public/#{page}.json"
      delete_file(directory)
      File.open(directory,"w") do |f|
        f.write(data.to_json)
      end
    end

    def delete_file directory
      begin
        File.open(directory, 'r') do |f|
          File.delete(f)
        end
      rescue Errno::ENOENT
      end
    end
end
