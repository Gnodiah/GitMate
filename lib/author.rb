require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
	adapter:  'sqlite3',
	database: 'db/gitmate.db'
)

# ActiveRecord::Schema.define do
# 	drop_table :authors
#
# 	create_table :authors do |t|
# 		t.string :name,  null: false
# 		t.string :email, null: false
#
# 		t.timestamps
# 	end
# 	create_table :daily_code_lines do |t|
# 		t.integer :author_id,   null: false
# 		t.date    :date,        null: false
# 		t.integer :addtions,    null: false, default: 0
# 		t.integer :deletions,   null: false, default: 0
#
# 		t.timestamps
# 	end
# 	add_index :daily_code_lines, [:author_id, :date], unique: true
# end

class Author < ActiveRecord::Base
	has_many :daily_code_lines

	validates :name, presence: true, uniqueness: true

  def code_lines(date, repo_name)
    # TODO: 要加上git remote update -p;
    result = "cd /home/weihd/Documents/#{repo_name};git log --all --pretty='%H' --after='#{date} 00:00' --before='#{date} 23:59' --author='#{name}' --numstat | awk 'NF==3 {plus+=$1;minus+=$2;} END {printf(\"" + "+%d, -%d\\n\"" + ", plus, minus)}'"

    %x[ #{result} ].scan(/\w+/)
  end

	def self.create_authors
		authors = %x[ cd /home/weihd/Documents/tao800_fire;git log --format='%aN:%aE' | sort -u ].split(/\n/)
		authors.each do |author|
			author = author.split(':')
			self.where(name: author.first, email: author.last).first_or_create
		end
	end
end


class DailyCodeLine < ActiveRecord::Base
	belongs_to :authors
end

class Repository < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	validates :url,  presence: true, uniqueness: true

	def self.create_repositories
		repo_url  = %x[ cd /home/weihd/Documents/tao800_fire;;git config --get remote.origin.url ]
		repo_name = repo_url.split('/').last.split('.').first
		self.where(name: repo_name, url: repo_url).first_or_create
	end
end
