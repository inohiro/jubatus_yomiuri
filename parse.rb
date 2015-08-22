require 'pry'

$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'utils/article'
require 'utils/article_reader'

def main
  reader = Utils::ArticleReader.new
  binding.pry
end

main
