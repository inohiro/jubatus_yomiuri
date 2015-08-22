module Utils
  class Article
    def initialize(entry)
      @entry = entry
    end

    def date_id
      @date_id ||= @entry['DateId'].first
    end

    def news_item_id
      @news_item_id ||= @entry['NewsItemId'].first
    end

    def date_line
      @date_line ||= @entry['DateLine']
    end

    def head_line
      @head_line ||= @entry['HeadLine'].first
    end

    def articles
      @articles ||= @entry['article'].map {|entry| entry.gsub('　', '') }
    end

    def genres
      [genre1, genre2]
    end

    def genre1
      @genre1 ||= @entry['Genre1']
    end

    def genre2
      @genre2 ||= @entry['Genre1']
    end

  end
end
