#!/usr/bin/env ruby

HOST = '127.0.0.1'
PORT = 9199
NAME = 'test'

require 'pry'
require 'json'
require 'jubatus/recommender/client'
require 'parallel'

$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'utils/article'
require 'utils/article_reader'

require 'pp'

def main
  rand_seed = nil
  reader = Utils::ArticleReader.new(rand_seed)
  ids_and_titles = reader.articles[1..10].map {|article| [article.id, article.title] }

  client = Jubatus::Recommender::Client::Recommender.new(HOST, PORT, NAME)
  ids_and_titles.each do |id, title|
    related_article = client.similar_row_from_id(id, 4)
    puts "#{title} is similar to"

    related_article[1..3].map {|article|
      [article.id, article.score]
    }.each {|id, score|
      article = reader.find_article_by_id(id)
      puts "\t#{article.title},\t#{score}" if article
    }
  end
end

main
