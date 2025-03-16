require_relative '../data/constants'

class BotResponseService
    def initialize(bot)
        @bot = bot
    end

	def start_message(user)
		send_message(user[DBFields::TELEGRAM_CHAT_ID], "#{InfoMessages::START_MESSAGE} #{user[DBFields::FIRST_NAME]}!")
	end

	def send_message(chat_id, message)
		@bot.api.send_message(chat_id: chat_id, text: message)
	end

	def send_message_with_parse(chat_id, message)
		@bot.api.send_message(chat_id: chat_id, text: message, parse_mode: "HTML")
	end

	def send_image(chat_id, imagePath)
		@bot.api.send_photo(chat_id: chat_id, photo: Faraday::UploadIO.new(
            imagePath, "image/#{File.extname(imagePath)}"))
	end

	def send_image_with_caption(chat_id, imagePath, caption)
		@bot.api.send_photo(chat_id: chat_id, photo: Faraday::UploadIO.new(
            imagePath, "image/#{File.extname(imagePath)}"), caption: caption)
	end
end