require 'sinatra'
require 'sqlite3'
require 'slim'
require_relative 'lib/author'

# Close database connection after each request, for solving problem: 
# ActiveRecord::ConnectionTimeoutError (could not obtain a database connection within 5 seconds)
after { ActiveRecord::Base.connection.close }

helpers do
	def author_exists?(author_id, repo_id)
    DailyCodeLine.where(author_id: author_id, repository_id: repo_id).present?
	end

	def find_code_lines(author_id, repo_id, date)
    DailyCodeLine.find_by(author_id: author_id, repository_id: repo_id, date: date)
	end

	def generate_repo
		request.get? ? @repositories.first.id : @repository.id
	end

	def generate_date
		request.get? ? Date.today.to_s(:db) : params[:date]
	end
end

get '/' do
	@authors = Author.all
	@repositories = Repository.all
  # @authors.sort! { |x, y| y[:total] <=> x[:total] }

	slim :authors
end

get '/repos' do
	@repositories = Repository.all

	slim :repos
end

post '/' do
	@authors = Author.all
	@repositories = Repository.all

	@repository = Repository.find_by(name: params[:repo_name])
	if @repository.present? #&& DailyCodeLine.count(repository_id: @repository.id, date: params[:date]) == 0
		@authors.each do |author|
			lines = author.code_lines(params[:date], @repository.name)
			DailyCodeLine.where(author_id: author.id, repository_id: @repository.id, date: params[:date],
													 addtions: lines.first.to_i, deletions: lines.last.to_i).first_or_create
		end
	end

	slim :authors
end

# To build data
# 初始化数据应该只执行一次,之后有必要也可以手动更新
get '/building' do
	Author.create_authors
	Repository.create_repositories

	Author.all.each do |author|
    lines = author.code_lines(Date.today.to_s(:db))
		DailyCodeLine.where(author_id: author.id, repository_id: Repository.first.id, date: Date.today.to_s(:db),
												 addtions: lines.first.to_i, deletions: lines.last.to_i).first_or_create
  end
end
