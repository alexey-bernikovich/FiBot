class DBTableNames
  BOT_USER_TABLE = "t_botuser"
  BLOCK_BOT_USER_TABLE = "t_blockbotuser"
  FILE_PATH_TABLE = "t_FilePath"
  BOT_USER_PATH_SAVE = "t_botuserpathsave"
end

class DBFuncNames
  GET_VIEWED_COUNT = "get_viewed_count"
  GET_AVAILABLE_PATHS = "get_available_paths"
  GET_STEAM_GAME_NAME = "get_steam_game_name"
  RESET_USER_SAVE_PATHS = "resetusersavepaths"
end

class DBFields
  ID = "id"
  TELEGRAM_CHAT_ID = "telegramchatid"
  BOT_USER_ID = "botuser_id"
  BOT_USER_ROLE_ID = "botuserrole_id"  
  FILE_TYPE_ID = "filetype_id"
  FILE_PATH_ID = "filepath_id"
  PATH = "path"
  IS_CENSORED = "iscensored"
  FIRST_NAME = "firstname"
end

class DBConstValues
  USER = 1
  TRUSTED = 2
  ADMIN = 3
  FILE_TYPE_PHOTO = 1
  FILE_TYPE_SCREEN = 2
end

class ErrorMessages
  MAINTENANCE_MODE = "Ведутся технические работы, бот временно недоступен"
  USER_IS_BLOCKED = "Вы заблокированы"  
  INVALID_COMMAND = "Команда не распознана"
  INSUFFICIENT_PERMISSIONS = "У вас нет прав для выполнения этой операции"
  VIEWED_ALL_PHOTOS = "Вы просмотрели все фото"
  EXCEPTION_OCCURRED = "Произошла ошибка, попробуйте ещё"
  VIEWED_ALL_SCREENS = "Вы просмотрели все Steam-скрины"
  WRONG_MONITOR_NUBMER = "Неверный номер монитора"
end

class InfoMessages
  START_MESSAGE = "Фикаро приветствует Вас,"
end

class SuccessMessages
  SET_BLUR_OK = "Режим замыливания дексто-скринов:"
  RESET_RAND_PHOTO = "История просмотренных фото очищена"
  RESET_RAND_SCREEN = "История просмотренных Steam-скринов очищена"
end