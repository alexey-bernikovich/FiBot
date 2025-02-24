require_relative '../services/bot_response_service'
require_relative '../services/bot_user_service'
require_relative '../services/permission_service'
require_relative '../services/rand_photo_service'
require_relative '../services/rand_screen_service'
require_relative '../services/screenshot_service'
require_relative '../services/information_service'
require_relative '../data/constants'

class BotController
    def initialize(logHandler, settings, bot, database)
        @logHandler = logHandler
        @settings = settings

        @botResponseService = BotResponseService.new(bot)
        @botUserService = BotUserService.new(logHandler, database, @botResponseService)
        @permissionService = PermissionService.new(@botUserService, @settings)
        @randPhotoService = RandPhotoService.new(logHandler, database, @botResponseService, @botUserService, @permissionService)
        @randScreenService = RandScreenService.new(logHandler, database, @botResponseService, @botUserService, @permissionService)
        @screenshotService = ScreenshotService.new(logHandler, @settings, @botResponseService, @permissionService)
        @informationService = InformationService.new(logHandler, @settings, @botResponseService, @botUserService, 
            @randPhotoService, @randScreenService, @permissionService)
    end

    def handle_message(message)
        chat_id = message.from.id
        
        @botUserService.create_user_if_not_exist(message)
 
        if @settings['debug_mode'] && !@permissionService.is_admin?(chat_id)
            @botResponseService.send_message(chat_id, ErrorMessages::MAINTENANCE_MODE)
            return
        end

        if @botUserService.user_is_blocked?(chat_id)
            @logHandler.log_info("User #{chat_id} is bloked")
            @botResponseService.send_message(chat_id, ErrorMessages::USER_IS_BLOCKED)
            return
        end

        @logHandler.log_info("User #{chat_id} (#{message.from.first_name}) message: #{message.text}")

        case message.text
            when /^\/start$/
                @botResponseService.start_message(chat_id, message)
            when /^\/screen(?: (\d+))?$/
                @screenshotService.send_desktop_screenshot(message, $1 ? $1 : 0)
            when /^\/blur$/
                @screenshotService.set_blur_mode(chat_id)
            when /^\/gamescreen$/
                @randScreenService.send_rand_screen(message)
            when /^\/resetgamescreens$/
                @randScreenService.reset(chat_id)
            when /^\/randphoto$/
                @randPhotoService.send_rand_photo(message)
            when /^\/resetphotos$/
                @randPhotoService.reset(chat_id)
            when /^\/stat$/
                @informationService.send_stats(chat_id)
            when /^\/updates$/
                @informationService.send_updates(chat_id)
            else
                @logHandler.log_info("Invalid command from #{chat_id}")
                @botResponseService.send_message(chat_id, ErrorMessages::INVALID_COMMAND)
        end
    end
end