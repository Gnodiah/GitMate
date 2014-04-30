require 'sinatra'
require 'sqlite3'

get '/' do
	db = SQLite3::Database.open 'gitmates.db'
	db.results_as_hash = true

	@authors = db.execute 'SELECT * FROM authors'

	erb :index
end
