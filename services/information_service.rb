class InformationService
    def initialize(logHandler, settings, botResponseService, botUserService, 
            randPhotoService, randScreenService, permissionService)
        @logHandler = logHandler
        @settings = settings
        @botResponseService = botResponseService
        @botUserService = botUserService
        @randPhotoService = randPhotoService        
        @randScreenService = randScreenService
        @permissionService = permissionService
    end

    def send_stats(user)
        chat_id = user[DBFields::TELEGRAM_CHAT_ID]
        user_id = user[DBFields::ID]

        if !@permissionService.can_execute_command?(user, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to view statistics")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        photo_stat = @randPhotoService.get_stat(user)
        screen_stat = @randScreenService.get_stat(user)

        @botResponseService.send_message_with_parse(chat_id,
            "Просмотрено <b>#{photo_stat[1]}</b> фото из <b>#{photo_stat[0]}</b>."\
            "\nЕще доступно: <b>#{photo_stat[0] - photo_stat[1]}</b> фото"\
            "\nПросмотрено <b>#{screen_stat[1]}</b> Steam-скринов из <b>#{screen_stat[0]}</b>."\
            "\nЕще доступно: <b>#{screen_stat[0] - screen_stat[1]}</b> скринов")
    end

    def send_updates(user)
        message_text = ""
        File.open(@settings['updates_path'], "r") do |file|
            message_text += file.read
        end
        @botResponseService.send_message_with_parse(user[DBFields::TELEGRAM_CHAT_ID], message_text)
    end
end