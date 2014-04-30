require 'sinatra'
require 'sqlite3'
require_relative 'author'

get '/' do
	db = SQLite3::Database.open 'gitmates.db'
	db.results_as_hash = true

	@authors = db.execute 'SELECT * FROM authors'

  @authors.each do |author|
    lines = Author.code_lines(author['name'])
    author[:addtions] = lines.first.to_i
    author[:deletions] = lines.last.to_i
    author[:total] = lines.first.to_i + lines.last.to_i
  end
  @authors.sort! { |x, y| y[:total] <=> x[:total] }


	erb :index
end
