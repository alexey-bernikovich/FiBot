# coding: UTF-8
require "win32/screenshot"

class Command

	SCREEN_PATH = "./data/screen.png"
	INVALID_MESSAGE = "Не понимаю тебя."
	MAX_PHOTO_SIZE = 10

	def initialize(bot)
		@photos = Array.new	
		@bot = bot
		@screenMode = false

		File.open("data/images_path.txt", "r:UTF-8") do |x|
			x.each_line do |line|
				@photos += Dir[line.gsub(/\x0A/, '') + "/*{jpg}"]
			end
		end
	end

#Commands

	def Start(message)
		@bot.api.send_message(
			chat_id: message.chat.id,
			text: "Дорова #{message.from.first_name}!")			
	end

	def Screen(message)
		unless @screenMode		 
			@bot.api.send_message(
				chat_id: message.chat.id,
				text: "Держи:")

			Win32::Screenshot::Take.of(:desktop).write!(SCREEN_PATH)			

			@bot.api.send_photo(
				chat_id: message.chat.id,
				photo: Faraday::UploadIO.new(SCREEN_PATH, 'image/png'))

			if message.from.id != ADMIN_ID
				@bot.api.send_message(
					chat_id: ADMIN_ID,
					text: "Screen for #{message.from.first_name}")
				@bot.api.send_photo(
					chat_id: ADMIN_ID,
					photo: Faraday::UploadIO.new(SCREEN_PATH, 'image/png'))
			end
		else
			@bot.api.send_message(
				chat_id: message.chat.id,
				text: "Не-а.")				
		end
	end 

	def RandPhoto(message)
		randId = 0
		size = 0
		loop do
			randId = rand(0..@photos.length - 1)
			size = (File.size(@photos[randId]).to_f / 2**20).round(2)
			break if size < MAX_PHOTO_SIZE

			puts "Fund more #{MAX_PHOTO_SIZE}mb!"
		end		

		@bot.api.send_photo(
			chat_id: message.chat.id,
			photo: Faraday::UploadIO.new(@photos[randId], 'image/jpg'))		

		if message.from.id != ADMIN_ID			
			@bot.api.send_message(
				chat_id: ADMIN_ID,
				text: "Photo for #{message.from.first_name}")
			@bot.api.send_photo(
				chat_id: ADMIN_ID,
				photo: Faraday::UploadIO.new(@photos[randId], 'image/jpg'))
		end
	end

	def SetScreen(message)
		if message.from.id == ADMIN_ID
			screenMode = !screenMode
			@bot.api.send_message(
				chat_id: ADMIN_ID,
				text: "Screen block mode: #{screenMode}")				
		else
			InvalidCommand()
		end
	end

	def Updates(message)
		text = ""
		File.open("data/updates.txt", "r:UTF-8") do |x|
			x.each_line do |line|
				text += line
			end
		end
		@bot.api.send_message(
			chat_id: message.chat.id,
			text: text)
	end

	def InvalidCommand(bot, message)
		@bot.api.send_message(
			chat_id: message.chat.id,
			text: INVALID_MESSAGE)
	end
end