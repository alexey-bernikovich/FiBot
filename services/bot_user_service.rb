require_relative '../models/bot_user_model'

class BotUserService
    def initialize(logHandler, database, botResponseService)
        @logHandler = logHandler
        @botUserModel = BotUserModel.new(database)
        @botResponseService = botResponseService
    end

    def find_user(chat_id)
        return @botUserModel.find_user(chat_id)
    end

    def get_user_role(chat_id)
        return @botUserModel.get_user_role(chat_id)
    end

    def user_is_blocked?(chat_id)
        return @botUserModel.user_is_blocked(chat_id)
    end

    def create_user_if_not_exist(message)
        user = find_user(message.from.id)
        if user == nil
            create_user(message.from.id, message.from.first_name)
        end
    end

    def create_user(chat_id, first_name)
        @botUserModel.create_user(chat_id, first_name)
        created_user = @botUserModel.find_user(chat_id)
        @logHandler.log_info("Created a new user: id#{created_user[DBFields::ID]}")
    end
end