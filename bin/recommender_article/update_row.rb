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

def main
  rand_seed = 0
  reader = Utils::ArticleReader.new(rand_seed)

  client = Jubatus::Recommender::Client::Recommender.new(HOST, PORT, NAME)
  update(client, reader.articles)

  # predict(client, remain_titles, remain_articles, remain_genre1s)
  # save_model(client)
end

def update(client, articles)
  Parallel.map(articles, in_threads: 8) {|article|
    [ article.id,
      Jubatus::Common::Datum.new(
        title: article.title,
        # paragraphs: article.joined_paragraph_nouns
        paragraphs: article.joined_paragraphs
      )
    ]
  }.each {|article_id, datum|
    client.update_row(article_id, datum)
  }
end

def save_model(client)
  client.save(NAME)
end

main
