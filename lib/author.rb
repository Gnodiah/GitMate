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

  def code_lines(date, repo_dir)
    # TODO: 要加上git remote update -p;应该在载入程序后自动将所有项目都update一下，
		# 而不是到这里才update。因为每次计算代码行数才update会很浪费时间且导致重复update
    result = "cd #{repo_dir};git log --all --pretty='%H' --after='#{date} 00:00' --before='#{date} 23:59' --author='#{name}' --numstat | awk 'NF==3 {plus+=$1;minus+=$2;} END {printf(\"" + "+%d, -%d\\n\"" + ", plus, minus)}'"

    %x[ #{result} ].scan(/\w+/)
  end
end


class DailyCodeLine < ActiveRecord::Base
	belongs_to :authors
end
