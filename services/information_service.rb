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

    def send_stats(chat_id)
        if !@permissionService.can_execute_command?(chat_id, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to view statistics")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        user_id = @botUserService.find_user(chat_id)[DBFields::ID]

        photo_stat = @randPhotoService.get_stat(user_id)
        screen_stat = @randScreenService.get_stat(user_id)

        @botResponseService.send_message_with_parse(chat_id,
            "Просмотрено <b>#{photo_stat[1]}</b> фото из <b>#{photo_stat[0]}</b>."\
            "\nЕще доступно: <b>#{photo_stat[0] - photo_stat[1]}</b> фото"\
            "\nПросмотрено <b>#{screen_stat[1]}</b> Steam-скринов из <b>#{screen_stat[0]}</b>."\
            "\nЕще доступно: <b>#{screen_stat[0] - screen_stat[1]}</b> скринов")
    end

    def send_updates(chat_id)
        message_text = ""
        File.open(@settings['updates_path'], "r") do |file|
            message_text += file.read
        end
        @botResponseService.send_message_with_parse(chat_id, message_text)
    end
end