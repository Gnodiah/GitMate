class CreateAuthors < ActiveRecord::Migration
	def change
		create_table :authors do |t|
			t.string :name,  null: false, limit: 50
			t.string :email, null: false, limit: 100

			t.timestamps
		end
	end
end
