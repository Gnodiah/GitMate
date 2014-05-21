require 'yaml'

module Configuration
	def self.root_path=(path)
		@root_path = path
	end

	def self.root_path
		@root_path
	end

	def self.load
		config_file = "#{self.root_path}/config/repository.yml"

		return false if !File.exists?(config_file)
		YAML.load(File.open(config_file))
  end
end
