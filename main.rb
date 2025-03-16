# coding: UTF-8
require 'telegram/bot'
require_relative 'lib/config_loader'
require_relative 'lib/log_handler'
require_relative 'db/database'
require_relative 'controllers/bot_controller'

config = ConfigLoader.load_config
settings = config['misc']
logHandler = LogHandler.new(settings['log_file_path'])
database = Database.new(config['database'])

Telegram::Bot::Client.run(config['telegram']['token']) do |bot|	
	botController = BotController.new(logHandler, config, bot, database)
	
	if settings['debug_mode']
		logHandler.log_debug("Launched in the debug mode")	
	end

	logHandler.log_info("Bot is ready")

	bot.listen do |message|
		begin
			logHandler.log_info("Resieved a message: chat_id #{message.from.id}")
			if message != nil
				botController.handle_message(message)
			else
				logHandler.log_error("Nil request #{e}")
			end
		rescue Exception => e
			logHandler.log_error("FATAL ERROR #{e}")
		end
	end
end