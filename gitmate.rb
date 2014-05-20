require 'sinatra'
require 'sqlite3'
require 'slim'
require_relative 'lib/repository'

# Close database connection after each request, for solving problem: 
# ActiveRecord::ConnectionTimeoutError (could not obtain a database connection within 5 seconds)
after { ActiveRecord::Base.connection.close }

# Set the application's ROOT path
configure do
	Repository.root_path = settings.root
end

helpers do
	def author_exists?(author_id, repo_id)
    DailyCodeLine.where(author_id: author_id, repository_id: repo_id).present?
	end

	def find_code_lines(author_id, repo_id, begin_date, end_date)
    # DailyCodeLine.find_by(author_id: author_id, repository_id: repo_id, date: date)
		end_date = begin_date if end_date.blank?
    DailyCodeLine.where(author_id: author_id, repository_id: repo_id)
								 .where("date >= ? AND date <= ?", begin_date, end_date)
	end

	def generate_repo
		request.get? ? @repositories.first.id : @repository.id
	end

	def generate_begin_date
		request.get? ? Date.today.to_s(:db) : params[:begin_date]
	end
end

get '/' do
	@authors = Author.all
	@repositories = Repository.all
  # @authors.sort! { |x, y| y[:total] <=> x[:total] }
  @code_lines = {}
  repo = Repository.first
  @authors.each do |author|
    @code_lines[author.id] = author.code_lines(generate_begin_date, generate_begin_date, repo.dir)
  end
  STDOUT.puts  @code_lines

	slim :authors
end

get '/repos' do
	@repositories = Repository.all

	slim :repos
end

post '/' do
	@authors = Author.all
	@repositories = Repository.all
  @code_lines = {}

	@repository = Repository.find_by(name: params[:repo_name])
  # DailyCodeLine.transaction do
    if @repository.present? #&& DailyCodeLine.count(repository_id: @repository.id, date: params[:date]) == 0
			begin_date = params[:begin_date].blank? ? Date.today : Date.parse(params[:begin_date])
			end_date = params[:end_date].blank? ? begin_date : Date.parse(params[:end_date])
			#(end_date - begin_date + 1).to_i.times do
				@authors.each do |author|
					#dc = DailyCodeLine.where(author_id: author.id, repository_id: @repository.id, date: begin_date).first_or_create
          lines = author.code_lines(begin_date, end_date, @repository.dir)
          @code_lines[author.id] = lines
					# dc.update_attributes(addtions: lines.first.to_i, deletions: lines.last.to_i)
				end
				#begin_date = begin_date.next_day if begin_date.present?
			#end
    end
  # end
    puts @code_lines

	slim :authors
end

# To build data
# 初始化数据应该只执行一次,之后有必要也可以手动更新
get '/building' do
	unless Repository.create_repos_and_authors
		@errors = "It seems that you don't have the configuration file: #{settings.root}/config/repository.yml. 
							 You should go create it, which configures the repositories' directories. 
							 After that, you can click 'Building Data' to rebuild data."
	end

	defined?(@errors) ? "#{@errors}" : redirect('/')
	# Author.all.each do |author|
  #   lines = author.code_lines(Date.today.to_s(:db))
	# 	DailyCodeLine.where(author_id: author.id, repository_id: Repository.first.id, date: Date.today.to_s(:db),
	# 											 addtions: lines.first.to_i, deletions: lines.last.to_i).first_or_create
  # end
end
