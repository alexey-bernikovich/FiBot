require 'yaml'

class ConfigLoader
    def self.load_config
        config = YAML.load_file('config/config.yml')
    end
end