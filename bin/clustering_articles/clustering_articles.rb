#!/usr/bin/env ruby

require 'json'
require 'jubatus/clustering/client'
require 'pry'

$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'utils/article'
require 'utils/article_reader'

class Application
  HOST = '127.0.0.1'
  PORT = 9199
  NAME = 'test'
  RAND_SEED = 10

  def main
    reader = Utils::ArticleReader.new(RAND_SEED)

    titles = reader.titles
    genre1s = reader.genre1s

    train_titles = titles[0..300]
    # train_genre1s = genre1s[0..100]

    client = Jubatus::Clustering::Client::Clustering.new(HOST, PORT, NAME)
    client.push(train_titles.map{|title| Jubatus::Common::Datum.new(title: title)})

    centers = client.get_k_center
  end
end

Application.new.main
