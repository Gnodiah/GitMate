class AddIndexToAuthors < ActiveRecord::Migration
	def change
		add_index :authors, [:name, :email], unique: true
	end
end
