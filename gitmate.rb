require 'sinatra'
require 'sqlite3'
require 'slim'
require_relative 'lib/repository'

# Close database connection after each request, for solving following problem: 
# ActiveRecord::ConnectionTimeoutError (could not obtain a database connection within 5 seconds)
after { ActiveRecord::Base.connection.close }

# Set the application's ROOT path
configure do
	Configuration.root_path = settings.root
	enable :logging
end

helpers do
  def begin_date
    params[:begin_date].blank? ? Date.today.prev_day : Date.parse(params[:begin_date])
  end

  def end_date
    params[:end_date].blank? ? begin_date : Date.parse(params[:end_date])
  end
end

get '/' do
	@repositories = Repository.all
	@repository 	= @repositories.first
  @code_lines 	= {}

  @repository.authors.each do |author|
    code_lines = author.code_lines(begin_date, end_date, @repository.dir)
		code_lines << code_lines.inject(:+)
    code_lines << author # Add current author object for sorting
		@code_lines[author.id] = code_lines
	end

	# Sort the result according to total code lines
  @sorted_code_lines = @code_lines.sort { |x, y| y.last[2] <=> x.last[2] }.map { |c| c.last }

	slim :authors
end

post '/' do
	@repository = Repository.find_by(name: params[:repo_name])
	halt 404, "This repository doesn't exist." if @repository.blank?

	@repositories = Repository.all
  @code_lines 	= {}

	@repository.authors.each do |author|
		code_lines = author.code_lines(begin_date, end_date, @repository.dir)
		code_lines << code_lines.inject(:+)
    code_lines << author
		@code_lines[author.id] = code_lines
	end

	# Sort the result according to total code lines
  @sorted_code_lines = @code_lines.sort { |x, y| y.last[2] <=> x.last[2] }.map { |c| c.last }

	slim :authors
end

get '/commits' do
	'In processing...'
end

get '/repos' do
	@repositories = Repository.all

	slim :repos
end

# To build data 
# 初始化数据应该只执行一次,之后有必要也可以手动更新
get '/building' do
	unless Repository.create_repos_and_authors
		halt 404, "It seems that you don't have the configuration file: #{settings.root}/config/repository.yml. 
							 You should go create it, which configures the repositories' directories. 
							 After that, you can click 'Building Data' to rebuild data."
	end

	redirect('/') # success
end
