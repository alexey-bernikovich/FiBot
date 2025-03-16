class BotUserService
    def initialize(logHandler, botUserRepository, botResponseService)
        @logHandler = logHandler
        @botUserRepository = botUserRepository
        @botResponseService = botResponseService
    end

    def get_or_create_user(message)
        user = @botUserRepository.get(message.from.id)
        if user == nil
            user = @botUserRepository.set(message.from.id, message.from.first_name)
            if user != nil
                @logHandler.log_info("Created a new user: id: #{user[DBFields::ID]}, name: #{user[DBFields::FIRST_NAME]}")
            end
        end
        return user
    end

    def get_user_role(user)
        return user[DBFields::BOT_USER_ROLE_ID]
    end

    def user_is_blocked?(user)
        return @botUserRepository.user_is_blocked?(user[DBFields::ID])
    end
end