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

  def code_lines(begin_date, end_date, repo_dir)
    # TODO: 要加上git remote update -p;应该在载入程序后自动将所有项目都update一下，
		# 而不是到这里才update。因为每次计算代码行数才update会很浪费时间且导致重复update
    result = "cd #{repo_dir};git log --all --pretty='%H' --after='#{begin_date} 00:00' --before='#{end_date} 23:59' --author='#{name}' --numstat | awk 'NF==3 {plus+=$1;minus+=$2;} END {printf(\"" + "+%d, -%d\\n\"" + ", plus, minus)}'"

    %x[ #{result} ].scan(/\w+/).map!(&:to_i)
  end

	# Check if this author has contributed to the given repository
	def contributed_to? repo
    authors = %x[ cd #{repo.dir};git log --format='%aN:%aE' | sort -u ].split(/\n/)
    authors.map! { |author| author.split(':').first }

		authors.include? name
	end
end


class DailyCodeLine < ActiveRecord::Base
	belongs_to :authors

  class << self
    def build_by_repository repo_name
      repository = Repository.find_by(name: repo_name)
      puts "This repository doesn't exist." && return if repository.blank?

      authors    = repository.authors
      DailyCodeLine.transaction do
        begin_date = params[:begin_date].blank? ? Date.today : Date.parse(params[:begin_date])
        end_date = params[:end_date].blank? ? begin_date : Date.parse(params[:end_date])
        (end_date - begin_date + 1).to_i.times do
          @authors.each do |author|
            dc = DailyCodeLine.where(author_id: author.id, repository_id: @repository.id, date: begin_date).first_or_create
            lines = author.code_lines(begin_date, @repository.dir)
            dc.update_attributes(addtions: lines.first.to_i, deletions: lines.last.to_i)
          end
          begin_date = begin_date.next_day if begin_date.present?
        end
      end
    end
  end
end
