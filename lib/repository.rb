require 'active_record'
require 'yaml'
require_relative 'author'

class Repository < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	validates :url,  presence: true, uniqueness: true

	def self.root_path=(path)
		@root_path = path
	end

	def self.root_path
		@root_path
	end

	CONFIG_FILE = "/home/gnodiah/code/projects/GitMate/config/repository.yml"

	# Create all repositories and all authors of each repository
	def self.create_repos_and_authors
		STDOUT.puts CONFIG_FILE
		return false if !File.exists?(CONFIG_FILE)

		configs = YAML.load(File.open(CONFIG_FILE))
		Repository.transaction do
			configs.each do |name, dir|
				repo_url  = %x[ cd #{dir};git config --get remote.origin.url ]
				# repo_name = name
				repo_name = repo_url.split('/').last.split('.').first

				repo = self.where(name: repo_name).first_or_create(url: repo_url, dir: dir)
				repo.update_attributes(url: repo_url, dir: dir)

				# Also create all authors of this repository
				self.create_authors(dir)
			end
		end
	end

	def self.create_authors(repo_dir)
		authors = %x[ cd #{repo_dir};git log --format='%aN:%aE' | sort -u ].split(/\n/)
		authors.each do |author|
			author = author.split(':')
			Author.where(name: author.first, email: author.last).first_or_create
		end
	end
end
