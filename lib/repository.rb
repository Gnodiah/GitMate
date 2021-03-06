require 'active_record'
require 'yaml'
require_relative 'author'
require_relative 'configuration'

class Repository < ActiveRecord::Base

	validates :name, presence: true, uniqueness: true
	validates :url,  presence: true, uniqueness: true

  # Return all authors of current repository
  def authors
    authors = %x[ cd #{dir};git log --format='%aN:%aE' | sort -u ].split(/\n/)
    authors.map! { |author| author.split(':').first }

    Author.where(name: authors)
  end

  class << self
    # Create all repositories and all authors of each repository
    def create_repos_and_authors
      return false unless (configs = fetch_all)

      Repository.transaction do
        configs.each do |name, dir|
          repo_url  = %x[ cd #{dir};git config --get remote.origin.url ]
          # repo_name = name
          repo_name = repo_url.split('/').last.split('.').first

          repo = self.where(name: repo_name).first_or_create(url: repo_url, dir: dir)
          repo.update_attributes(url: repo_url, dir: dir)

          # Also create all authors of this repository
          create_authors(dir)
        end
      end
    end

    def create_authors(repo_dir)
      authors = %x[ cd #{repo_dir};git log --format='%aN:%aE' | sort -u ].split(/\n/)
      authors.each do |author|
        author = author.split(':')
        Author.where(name: author.first, email: author.last).first_or_create
      end
    end

    # Fetch all branches in all repositories before create repositories
    def fetch_all
			logger.info Configuration.root_path
			# TODO: why cannot access Sinatra::Base.settings ?
			logger.info Sinatra::Base.settings.root
      return false unless (configs = Configuration.load)

      configs.each do |name, dir|
        logger.debug "----- Fetching #{name} start -----"
        %x[ cd #{dir};git fetch --all ]
        logger.debug "----- Fetching #{name} done  -----"
      end

      configs
    end
  end
end
