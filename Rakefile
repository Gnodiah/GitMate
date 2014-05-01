namespace :db do
	task :environment do
		require 'active_record'

		ActiveRecord::Base.logger = Logger.new(STDOUT)

		ActiveRecord::Base.establish_connection(
			adapter:  'sqlite3',
			database: 'db/gitmate.db'
		)
	end

	task :migrate => :environment do
		ActiveRecord::Migration.verbose = true
		ActiveRecord::Migrator.migrate('db/migrate')
	end

	task :rollback => :environment do
		ActiveRecord::Migration.verbose = true
		ActiveRecord::Migrator.rollback('db/migrate')
	end
end
