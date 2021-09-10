# coding: UTF-8
require 'telegram/bot'
require 'date'
require_relative 'data/data'
require_relative 'command/command'

@DebugMode = false
@DBManager = DBManager.new

Telegram::Bot::Client.run(TOKEN) do |bot|
	cmd = Command.new(bot, @DBManager)

	bot.listen do |message|
		if message != nil
			puts "|#{Time.at(message.date).strftime("%d/%m/%Y %T")}| #{message.from.first_name}(#{message.from.id}): #{message.text}"
			commandIsExist = true

			if @DebugMode && message.from.id != ADMIN_ID
				cmd.SendMessage(message.from.id, 
					"Технические работы. Возвращайтесь позже.")
				next
			else

				if @DBManager.UserIsExist(message.from.id) != 't'
					@DBManager.AddNewUser(message.from.id, message.from.first_name)
					puts "Add new user: #{message.from.id}"
				end

				if @DBManager.UserIsBlock(
					@DBManager.GetUserID(message.from.id)) != 't'

					case message.text
						when "/start"; cmd.Start(message)
						when "/updates"; cmd.Updates(message)
						when "/screen"; cmd.Screen(message)
						when "/gamescreen"; cmd.GameScreen(message)
						when "/randphoto"; cmd.RandPhoto(message)
						when "/resetrandphotos"; cmd.ResetUserImages(message, true)
						when "/resetgamescreens"; cmd.ResetUserImages(message, false)
						when "/unnotify"; cmd.SetNotify(message, false)
						when "/notify"; cmd.SetNotify(message, true)
						else
							commandIsExist = false
					end

					if(!commandIsExist && message.from.id == ADMIN_ID)
						commandIsExist = true
						case message.text
							when "/setScreen"; cmd.SetScreen(message)
							when "/notifyAll"; cmd.NotifyAll(message)
							else
								commandIsExist = false
						end
					end

					if !commandIsExist
						cmd.SendMessage(message.from.id, "Не понимаю Вас.")
					end
				else
					cmd.SendMessage(message.from.id, 
						"Вы заблокированы.")
				end
			end
		else
			puts "Nil request"
		end
	end
end