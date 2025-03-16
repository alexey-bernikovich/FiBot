require_relative '../services/bot_response_service'
require_relative '../services/bot_user_service'
require_relative '../services/permission_service'
require_relative '../services/rand_photo_service'
require_relative '../services/rand_screen_service'
require_relative '../services/screenshot_service'
require_relative '../services/information_service'
require_relative '../repos/bot_user_repository'
require_relative '../repos/rand_photo_repository'
require_relative '../repos/rand_screen_repository'
require_relative '../data/constants'
require_relative '../redis/redis_json_client'
require_relative '../redis/redis_handler'

class BotController
    def initialize(logHandler, config, bot, database)
        @logHandler = logHandler
        @settings = config['misc']
       
        redis_json_client = RedisJsonHandler.new(logHandler, config['redis'], RedisDb::USER_DB)
        redis_client = RedisHandler.new(logHandler, config['redis'], RedisDb::GAME_NAME_DB)        

        botUserRepository = BotUserRepository.new(logHandler, database, redis_json_client)
        randPhotoRepository = RandPhotoRepository.new(logHandler, database) 
        randScreenRepository = RandScreenRepository.new(logHandler, database, redis_client)

        @botResponseService = BotResponseService.new(bot)
        @botUserService = BotUserService.new(logHandler, botUserRepository, @botResponseService)
        @permissionService = PermissionService.new(@botUserService, @settings)
        @randPhotoService = RandPhotoService.new(logHandler, randPhotoRepository, @botResponseService, @botUserService, @permissionService)
        @randScreenService = RandScreenService.new(logHandler, randScreenRepository, @botResponseService, @botUserService, @permissionService)
        @screenshotService = ScreenshotService.new(logHandler, @settings, @botResponseService, @permissionService)
        @informationService = InformationService.new(logHandler, @settings, @botResponseService, @botUserService, 
            @randPhotoService, @randScreenService, @permissionService)
    end

    def handle_message(message)
        chat_id = message.from.id        
        user = @botUserService.get_or_create_user(message)
        
        if @settings['debug_mode'] && !@permissionService.is_admin?(user)
            @botResponseService.send_message(chat_id, ErrorMessages::MAINTENANCE_MODE)
            return
        end

        if @botUserService.user_is_blocked?(user)
            @logHandler.log_info("User #{chat_id} is bloked")
            @botResponseService.send_message(chat_id, ErrorMessages::USER_IS_BLOCKED)
            return
        end

        @logHandler.log_info("User #{chat_id} (#{message.from.first_name}) message: #{message.text}")

        case message.text
            when /^\/start$/
                @botResponseService.start_message(user)
            when /^\/screen(?: (\d+))?$/
                @screenshotService.send_desktop_screenshot(user, $1 ? $1 : 0)
            when /^\/blur$/
                @screenshotService.set_blur_mode(user)
            when /^\/gamescreen$/
                @randScreenService.send_rand_screen(user)
            when /^\/resetgamescreens$/
                @randScreenService.reset(user)
            when /^\/randphoto$/
                @randPhotoService.send_rand_photo(user)
            when /^\/resetphotos$/
                @randPhotoService.reset(user)
            when /^\/stat$/
                @informationService.send_stats(user)
            when /^\/updates$/
                @informationService.send_updates(user)
            else
                @logHandler.log_info("Invalid command from #{chat_id}")
                @botResponseService.send_message(chat_id, ErrorMessages::INVALID_COMMAND)
        end
    end
end