#!/usr/bin/env ruby

HOST = '127.0.0.1'
PORT = 9199
NAME = 'test'

require 'pry'
require 'json'
require 'jubatus/classifier/client'

$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'utils/article'
require 'utils/article_reader'

def main
  rand_seed = 10
  reader = Utils::ArticleReader.new(rand_seed)

  titles = reader.titles
  articles = reader.joined_articles
  genre1s = reader.genre1s

  train_length = 100

  train_titles = titles[0..train_length]
  train_articles = articles[0..train_length]
  train_genre1s = genre1s[0..train_length]

  remain_titles = titles[(train_length+1)..-1]
  remain_articles = articles[(train_length+1)..-1]
  remain_genre1s = genre1s[(train_length+1)..-1]

  client = Jubatus::Classifier::Client::Classifier.new(HOST, PORT, NAME)
  train(client, train_titles, train_articles, train_genre1s)
  predict(client, remain_titles, remain_articles, remain_genre1s)
  # save_model(client)
end

def train(client, titles, articles, genres)
  train_data = []

  genres.each_with_index do |genre, index|
    train_data << [
      genre || '',
      Jubatus::Common::Datum.new(
        title: titles[index] || '',
        article: articles[index]
      )
    ]
  end

  # train_data.sort_by{rand} # alreadly shuffled

  # run train
  client.train(train_data)
end

require 'pp'

def predict(client, titles, articles, genres)
  all = titles.size
  correct_num = 0

  titles.map {|title|
    Jubatus::Common::Datum.new(title: title)
  }.each_with_index {|title, index|
    result = client.classify([title])
    correct = genres[index]
    estimated_genre = result.first.max_by {|genre| genre.score }.label

    genre_and_score = result.first.map {|a| "#{a.label}: #{a.score}" }
    puts "correct: #{correct}, actual: #{estimated_genre}, #{genre_and_score.join(', ')}"
    # puts "correct: #{correct}, actual: #{estimated_genre},\t#{title}"
    correct_num += 1 if correct == estimated_genre
  }

  puts correct_num / (all * 1.0)
end

def save_model(client)
  client.save(NAME)
end

main
