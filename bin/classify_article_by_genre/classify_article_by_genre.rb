#!/usr/bin/env ruby

$host = "127.0.0.1"
$port = 9199
$name = "test"

require 'json'
require 'jubatus/classifier/client'

$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'utils/article'
require 'utils/article_reader'

require 'pry'

def main
  rand_seed = 1
  reader = Utils::ArticleReader.new(rand_seed)

  titles = reader.titles
  genre1s = reader.genre1s

  train_titles = titles[0..100]
  train_genre1s = genre1s[0..100]

  remain_titles = titles[101..-1]
  remain_renge1s = genre1s[101..-1]

  client = Jubatus::Classifier::Client::Classifier.new($host, $port, $name)
  train(client, train_titles, train_genre1s)
  predict(client, remain_titles, remain_renge1s)
end

def train(client, titles, genres)
  train_data = []

  genres.each_with_index do |genre, index|
    train_data << [
      genre,
      Jubatus::Common::Datum.new(title: titles[index])
    ]
  end

  # train_data.sort_by{rand} # alreadly shuffled

  # run train
  client.train(train_data)
end

require 'pry'

def predict(client, titles, genres)
  all = titles.size
  correct_num = 0

  titles.map {|title|
    Jubatus::Common::Datum.new(title: title)
  }.each_with_index {|title, index|
    result = client.classify([title])
    correct = genres[index]
    estimated_genre = result.first.max_by {|genre| genre.score }.label

    if correct == estimated_genre
      correct_num += 1
    end
  }

  puts correct_num / (all * 1.0)
end

main
