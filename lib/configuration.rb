require 'yaml'

module Configuration
	CONFIG_FILE = "/home/weihd/Documents/GitMate/config/repository.yml"

  def Configuration.load
		return false if !File.exists?(CONFIG_FILE)
		YAML.load(File.open(CONFIG_FILE))
  end
end
