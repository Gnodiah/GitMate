class AddDirToRepositories < ActiveRecord::Migration
	def change
		add_column :repositories, :dir, :string, null: false, default: ''

		add_index :repositories, :name, unique: true
	end
end
