# coding: UTF-8
require "win32/screenshot"
require "mini_magick"
require 'pg'
require_relative '../db_manager/db_manager' 
require_relative '../data/data'

class Command

	def initialize(bot, dbManager)
		@DBManager = dbManager
		@bot = bot
		@screenMode = false	
		@gameScreens = Array.new
		puts "Bot is ready!"
	end

	def Start(message)
		SendMessage(message.chat.id, 
			"Фикаро приветствует Вас, #{message.from.first_name}!")
	end

	# regular

	def Screen(message)
		SendMessage(message.chat.id, "Держи:")
		Win32::Screenshot::Take.of(:desktop, :hwnd=>1).write!(SCREEN_PATH)

		if @screenMode
			image = MiniMagick::Image.open(SCREEN_PATH)
			image.blur("0x32")
			image.write SCREEN_PATH
		end

		SendPhoto(message.chat.id, SCREEN_PATH)

		if message.from.id != ADMIN_ID
			SendMessage(ADMIN_ID, "Screen for #{message.from.first_name}")
			SendPhoto(ADMIN_ID, SCREEN_PATH)			
		end
	end 

	def RandPhoto(message)
		userId = @DBManager.GetUserID(message.from.id)
		values = @DBManager.GetAvailabeFiles(
			@DBManager.GetUserID(message.from.id), 1)
		randId = rand(0..values.length - 1)

		if values.length == 0
			SendMessage(message.chat.id, 'Вы просмотрели все фото.')
			if message.chat.id != ADMIN_ID
				SendMessage(ADMIN_ID, "#{message.chat.id} see all photos.")
			end
			return
		end

		path = @DBManager.GetFilePath(values[randId][0]);
		@DBManager.SavePathForUser(userId, values[randId][0])

		begin
			SendPhoto(message.chat.id, path)
			if message.from.id != ADMIN_ID
				SendMessage(ADMIN_ID, "Photo for #{message.from.first_name}")
				SendPhoto(ADMIN_ID, path)
			end
		rescue 
			puts "BAD photo path: #{path}"
		end
	end

	def GameScreen(message)
		userId = @DBManager.GetUserID(message.from.id)
		values = @DBManager.GetAvailabeFiles(
			@DBManager.GetUserID(message.from.id), 2)
		randId = rand(0..values.length - 1)

		if values.length == 0
			SendMessage(message.chat.id, 'Вы просмотрели все игровые скрины.')
			if message.chat.id != ADMIN_ID
				SendMessage(ADMIN_ID, "#{message.chat.id} see all game screens.")
			end
			return
		end

		path = @DBManager.GetFilePath(values[randId][0]);
		@DBManager.SavePathForUser(userId, values[randId][0])

		begin
			SendMessage(message.chat.id, 
				"#{File.ctime(path).strftime("%d/%m/%Y")}")
			SendPhoto(message.chat.id, path)

			if message.from.id != ADMIN_ID
				SendMessage(ADMIN_ID, "Game screen for #{message.from.first_name}")
				SendPhoto(ADMIN_ID, path)
			end
		rescue 
			puts "BAD photo path: #{path}"
		end
	end

	def Updates(message)		
		SendMessage(message.chat.id, GetUpdates())
	end

	def ResetUserImages(message, mode)
		@DBManager.ResetUserSavePaths(
			@DBManager.GetUserID(message.from.id), mode ? 1 : 2)
		SendMessage(message.from.id, "Ваш список #{mode ? "рандом фоток" : "игровых скринов"} очищен!")
	end

	def SetNotify(message, mode)
		userId = @DBManager.GetUserID(message.from.id)
		notifyStatus = @DBManager.GetUserNotificationStatus(userId)	
		if mode
			if notifyStatus != 't'
				@DBManager.AddNotifyForUser(userId)
				SendMessage(message.from.id, "Вы подписались на уведомления.")
				if message.from.id != ADMIN_ID
					SendMessage(ADMIN_ID, "Add notify for user #{message.from.first_name}")
				end
			else
				SendMessage(message.from.id, "Вы уже подписаны на уведомления.")
			end
		else
			if notifyStatus == 't'
				@DBManager.UnotifyUser(userId)
				SendMessage(message.from.id, "Вы отписались от уведомлений.")
				if message.from.id != ADMIN_ID
					SendMessage(ADMIN_ID, "Remove notify for user #{message.from.first_name}")
				end
			else
				SendMessage(message.from.id, "Вы не подписаны на уведомления.")
			end
		end
	end

	# admin

	def SetScreen(message)
		@screenMode = !@screenMode
		SendMessage(ADMIN_ID, "Screen blur mode: #{@screenMode}")
	end

	def NotifyAll(message)
		userIds = @DBManager.GetNotificationUsers()
		userIds.each do |userId|
			SendMessage(userId[0], "#{GetUpdates()}\n\n*Это автоматическое уведомление.\nИспользуйте /unnotify если желаете отказаться от последующих уведомлений.")
		end
		SendMessage(ADMIN_ID, "Notify #{userIds.length} users.")
	end	

	# common

	def GetUpdates
		text = ""
		File.open("data/updates.txt", "r:UTF-8") do |x|
			x.each_line do |line|
				text += line
			end
		end
		return text
	end

	def SendMessage(chatId, message)
		@bot.api.send_message(chat_id: chatId, text: message)
	end

	def SendPhoto(chatId, imagePath)
		@bot.api.send_photo(chat_id: chatId,
			photo: Faraday::UploadIO.new(imagePath, 
			"image/#{File.extname(imagePath)}"))
	end
end