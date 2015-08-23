require 'natto'

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
    alias :id :news_item_id

    def date_line
      @date_line ||= @entry['DateLine']
    end

    def head_line
      @head_line ||= @entry['HeadLine'].first
    end
    alias :title :head_line

    def articles
      @articles ||= @entry['article'].map {|article|
        cleanse(article.gsub('　', ''))
      }
    end
    alias :paragraphs :articles

    def joined_articles
      # articles.map(&:surface).join
      articles.each do |article|
        Paragraph.new(article)
      end
    end
    alias :joined_paragraphs :joined_articles

    def joined_article_nouns
      articles.map(&:nouns).join
    end
    alias :joined_paragraph_nouns :joined_article_nouns

    def genres
      [genre1, genre2]
      end

    def genre1
      @genre1 ||= @entry['Genre1']
    end

    def genre2
      @genre2 ||= @entry['Genre1']
    end

    def cleanse(str)
      NKF.nkf('-m0Z1 -w', str)
    end
    private :cleanse

    class Paragraph
      def initialize(sentence)
        @sentence = sentence
        @mecab = Natto::MeCab.new
      end

      def surfaces
        if @surfaces
          @surfaces
        else
          @surfaces = []
          @mecab.parse(@sentence) {|result| @surfaces << result.surface }
          @surfaces
        end
      end

      def features
        if @features
          @features
        else
          @features = []
          @mecab.parse(@sentence) {|result| @features << result.feature }
          @features
        end
      end

      def nouns
        if @nouns
          return @nouns
        else
          @nouns = []
          @mecab.parse(@sentence) do |result|
            @nouns << result.surface if result.feature.match('名詞')
          end
          @nouns
        end
      end
    end
  end
end
