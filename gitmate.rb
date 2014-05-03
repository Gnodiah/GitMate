require 'sinatra'
require 'sqlite3'
require 'slim'
require_relative 'lib/author'

get '/' do
	# TODO: 初始化数据库应该只执行一次！想想应该放在什么地方
	# Author.create_authors
	# Repository.create_repositories

	@authors = Author.all

  # @authors.each do |author|
  #   lines = author.code_lines
	# 	DailyCodeLine.create(author_id: author.id, repository_id: Repository.first.id, date: '2014-04-28',
	# 												addtions: lines.first.to_i, deletions: lines.last.to_i)
  # end
  #@authors.sort! { |x, y| y[:total] <=> x[:total] }


	slim :index
end

get '/repos' do
	@repositories = Repository.all

	slim :repos
end
