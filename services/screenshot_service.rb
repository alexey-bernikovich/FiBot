require 'mini_magick'

class ScreenshotService    
    @should_blur = false

    def initialize(logHandler, settings, botResponseService, permissionService)
        @logHandler = logHandler
        @screen_path = settings['screenshot_path']
        @max_monitor_count = settings['max_monitor_count']
        @blur_level = settings['blur_level']
        @botResponseService = botResponseService
        @permissionService = permissionService        
    end

    def send_desktop_screenshot(message, monitor_id)
        chat_id = message.from.id
        first_name = message.from.first_name

        if !@permissionService.can_execute_command?(chat_id, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to get desktop screenshot")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        if !valid_monitor?(monitor_id.to_i)
            @logHandler.log_info("Invalid monitor id #{monitor_id}")
            @botResponseService.send_message(chat_id, ErrorMessages::WRONG_MONITOR_NUBMER)
            return
        end

        @logHandler.log_info("Calling python script...")
        output = IO.popen("python ./lib/take_screenshot.py #{monitor_id} 2>&1", &:read)

        if $?.exitstatus != 0
            @logHandler.log_error("Python error:#{output}")
            @botResponseService.send_message(chat_id, ErrorMessages::EXCEPTION_OCCURRED)
        else
            if @should_blur
                to_blur = MiniMagick::Image.open(@screen_path)
                to_blur.blur(@blur_level)
                to_blur.write @screen_path
            end

            @logHandler.log_info("Sending a desktop screenshot (monitor id: #{monitor_id}) to #{chat_id}")
            @botResponseService.send_image_with_caption(chat_id, @screen_path, Time.now.strftime("%d/%m/%Y %H:%M"))

            if !@permissionService.is_admin?(chat_id)
                @botResponseService.send_image_with_caption(@permissionService.admin_id, @screen_path, 
                    "Screen for #{first_name}:")
            end
        end
    end

    def valid_monitor?(id)
        id >= 0 && id <= @max_monitor_count
    end

    def set_blur_mode(chat_id)
        if @permissionService.can_execute_command?(chat_id, DBConstValues::ADMIN)
            @should_blur = !@should_blur
            blur_mode_str = @should_blur ? "ON" : "OFF"
            @logHandler.log_info("Set blut mode to:#{blur_mode_str}")
            @botResponseService.send_message(chat_id, "#{SuccessMessages::SET_BLUR_OK} #{blur_mode_str}")
        else
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to set_blut_mode")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
        end
    end
end