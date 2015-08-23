require 'parallel'
require 'json'
require 'nkf'

module Utils
  class ArticleReader
    def initialize(rand_seed = nil)
      entries = JSON.parse(File.open(articles_path, 'r').read)
      srand rand_seed if rand_seed

      @articles = Parallel.map(entries, in_threads: 8) {|entry|
        Utils::Article.new(entry)
      }
      .reject {|article| article.head_line == nil }
      .sort_by{rand}
    end

    def articles_path
      case RUBY_PLATFORM
      when /linux/
        '/home/inohiro/tmp/yomiuri_dataset/articles.json'
      when /darwin/
        '/Users/inohiro/Downloads/yomiuri_dataset/articles.json'
      else
        puts 'Couldn\'t find articles.json'
        '/tmp/articles.json'
      end
    end
    private :articles_path

    attr_reader :articles

    def head_lines
      @head_lines ||= Parallel.map(@articles, in_threads: 8) do |article|
        article.head_line
      end
    end
    alias :titles :head_lines

    def genre1s
      @genre1s ||= Parallel.map(@articles, in_threads: 8) do |article|
        article.genre1
      end
    end

    def genre2s
      @genre2s ||= Parallel.map(@articles, in_threads: 8) do |article|
        article.genre2
      end
    end

  end
end
