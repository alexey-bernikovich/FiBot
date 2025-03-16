require_relative '../data/constants'

class RandScreenService
    def initialize(logHandler, randScreenRepository, botResponseService, botUserService, permissionService)
        @logHandler = logHandler
        @randScreenRepository = randScreenRepository
        @botResponseService = botResponseService
        @botUserService = botUserService
        @permissionService = permissionService
    end

    def send_rand_screen(user)
        chat_id = user[DBFields::TELEGRAM_CHAT_ID]
        user_id = user[DBFields::ID]
        first_name = user[DBFields::FIRST_NAME]

        if !@permissionService.can_execute_command?(user, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to get random screenshot")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        if viewed_all_screens?(user)
            @logHandler.log_info("User #{chat_id} (#{first_name}) viewed all Steam screens")
            @botResponseService.send_message(chat_id, ErrorMessages::VIEWED_ALL_SCREENS)
            return
        end

        available_ids = @randScreenRepository.get_available(user_id).shuffle
        rand_id = rand(0..available_ids.length - 1)
        screen_id = available_ids[rand_id]
        screen_path = @randScreenRepository.get_screen_by_id(screen_id)[DBFields::PATH]

        begin
            game_name = @randScreenRepository.get_steam_game_name(screen_id, screen_path)
            caption = "#{File.mtime(screen_path).strftime("%d/%m/%Y")}"

            if game_name != nil                
                caption.prepend("#{game_name}\n")
            else
                @logHandler.log_error("Failed to get game name (id: #{screen_id}, path: #{screen_path})")                
            end
            
            @botResponseService.send_image_with_caption(chat_id, screen_path, caption)            
            @randScreenRepository.save_path(user_id, screen_id)

            @logHandler.log_info("Saved Steam-screen (id: #{screen_id}, path: #{screen_path}) for #{first_name}")

            if !@permissionService.is_admin?(user)
                @botResponseService.send_image_with_caption(@permissionService.admin_id, screen_path, "Rand Steam-screen for #{first_name}:")
            end
        rescue Exception => e
            @logHandler.log_error("Send random Steam-screen (id: #{screen_id}, path: #{screen_path}) error: #{e}")
            @botResponseService.send_message(chat_id, ErrorMessages::EXCEPTION_OCCURRED)
        end
    end

    def viewed_all_screens?(user)
        viewed = @randScreenRepository.get_viewed_count(user[DBFields::ID])
        count = @randScreenRepository.get_screen_count
        return viewed == count
    end

    def get_stat(user)
        viewed = @randScreenRepository.get_viewed_count(user[DBFields::ID])
        count = @randScreenRepository.get_screen_count
        return count, viewed
    end

    def reset(user)
        chat_id = user[DBFields::TELEGRAM_CHAT_ID]
        user_id = user[DBFields::ID]

        if !@permissionService.can_execute_command?(user, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to reset rand Steam-screens")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        @randScreenRepository.reset_user_save_path(user_id)
        @logHandler.log_info("User id: #{user_id} reset all rand Steam-screenshots")
        @botResponseService.send_message(chat_id, SuccessMessages::RESET_RAND_SCREEN)
    end
end