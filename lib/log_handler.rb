require 'logger'

class LogHandler
    def initialize(log_file_path)
        @logger = Logger.new(File.open(log_file_path, 'a'))    
        @stdout_logger = Logger.new(STDOUT)
    end

    def log_info(message)
        @logger.info(message)
        @stdout_logger.info(message)
    end
    
    def log_error(message)
        @logger.error(message)
        @stdout_logger.error(message)
    end

    def log_debug(message)
        @logger.debug(message)
        @stdout_logger.debug(message)
    end
end