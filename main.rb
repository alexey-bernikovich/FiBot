# coding: UTF-8
require 'telegram/bot'
require 'date'
require_relative 'data/data'
require_relative 'command/command'

Telegram::Bot::Client.run(TOKEN) do |bot|
	cmd = Command.new(bot)

	bot.listen do |message|

		fromDate = Time.at(message.date) 
		puts "|#{fromDate}| #{message.from.first_name}: #{message.text}"

		case message.text
			when "/start"; cmd.Start(message)
			when "/updates"; cmd.Updates(message)
			when "/screen"; cmd.Screen(message)
			when "/rand_photo"; cmd.RandPhoto(message)
			when "/set_screen"; cmd.SetScreen(message)					
		end
	end
end
	#end
  	#rescue Telegram::Bot::Exceptions::ResponseError => e
    	#puts "Oups! Exception by Telegram: #{e.error_code}"
#end