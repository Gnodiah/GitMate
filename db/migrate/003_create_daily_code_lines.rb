class CreateDailyCodeLines < ActiveRecord::Migration
	def change
		create_table :daily_code_lines do |t|
			t.integer :author_id,      null: false
			t.integer :repository_id,  null: false
			t.date    :date,           null: false
			t.integer :addtions,       null: false, default: 0
			t.integer :deletions,      null: false, default: 0

			t.timestamps
		end

		add_index :daily_code_lines, [:author_id, :repository_id, :date], unique: true
	end
end
