# coding: UTF-8
require 'pg'
require_relative '../data/data'

class DBManager

	def initialize

	end

	def GetAvailabeFiles(userId, fileTypeId)
		idArray = Array.new
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("SELECT GetAvailabelFiles(#{userId}, #{fileTypeId})") do |result|
		  result.each do |row|
		  	idArray.push(row.values_at('getavailabelfiles'))
		  end
		end
		return idArray
	end

	def GetFilePath(pathId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		return conn.exec("SELECT path FROM 
			t_filepath WHERE t_filepath.id=#{pathId}")[0]['path']
	end

	def UserIsExist(telegramChatId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		return conn.exec("SELECT UserIsExistByChatId(#{telegramChatId})")[0]['userisexistbychatid']
	end

	def UserIsBlock(userId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		return conn.exec("SELECT UserIsBlock(#{userId})")[0]['userisblock']
	end

	def GetUserID(telegramChatId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		return conn.exec("SELECT t_BotUser.ID FROM t_BotUser 
			WHERE t_BotUser.TelegramChatID = #{telegramChatId}")[0]['id']
	end

	def AddNewUser(telegramChatId, firstName)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("INSERT INTO t_BotUser (telegramchatid, firstname) VALUES (#{telegramChatId}, '#{firstName}')")
	end

	def SavePathForUser(userId, filePathId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("INSERT INTO t_BotUserPathSave 
			(botuser_id, filepath_id) VALUES (#{userId}, #{filePathId})")
	end

	def ResetUserSavePaths(userId, fileTypeId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("CALL ResetUserSavePaths(#{userId}, #{fileTypeId})")
	end

	def GetNotificationUsers()
		idArray = Array.new
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("SELECT GetUsersIntoNotification()") do |result|
		  result.each do |row|
		  	idArray.push(row.values_at('getusersintonotification'))
		  end
		end
		return idArray		
	end

	def GetUserNotificationStatus(userId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		return conn.exec("SELECT BotUserNotificationStatus(#{userId})")[0]['botusernotificationstatus']
	end

	def AddNotifyForUser(userId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("INSERT INTO t_BotUserNotification (BotUser_ID) VALUES (#{userId})")
	end

	def UnotifyUser(userId)
		conn = PG.connect( dbname: DB_NAME, user: DB_LOGIN, password: DB_PASSWORD )
		conn.exec("DELETE FROM t_BotUserNotification WHERE BotUser_ID = #{userId}")
	end
end