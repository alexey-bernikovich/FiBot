require_relative '../data/constants'

class RandPhotoService
    def initialize(logHandler, randPhotoRepository, botResponseService, botUserService, permissionService)
        @logHandler = logHandler
        @randPhotoRepository = randPhotoRepository
        @botResponseService = botResponseService
        @botUserService = botUserService
        @permissionService = permissionService
    end

    def send_rand_photo(user)
        chat_id = user[DBFields::TELEGRAM_CHAT_ID]
        user_id = user[DBFields::ID]
        first_name = user[DBFields::FIRST_NAME]

        if !@permissionService.can_execute_command?(user, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to get random Steam-screenshot")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        if viewed_all_photo?(user)
            @logHandler.log_info("User #{chat_id} (#{first_name}) viewed all photo")
            @botResponseService.send_message(chat_id, ErrorMessages::VIEWED_ALL_PHOTOS)
            return
        end

        available_ids = @randPhotoRepository.get_available(user_id).shuffle
        rand_id = rand(0..available_ids.length - 1)
        photo_id = available_ids[rand_id]
        photo_path = @randPhotoRepository.get_photo_by_id(photo_id)[DBFields::PATH]
        
        begin
            @botResponseService.send_image(chat_id, photo_path)
            @randPhotoRepository.save_path(user_id, photo_id)
            @logHandler.log_info("Saved photo (id: #{photo_id}, path: #{photo_path}) for #{first_name}")

            if !@permissionService.is_admin?(user)
                @botResponseService.send_message(@permissionService.admin_id, "Rand photo for #{first_name}:")
                @botResponseService.send_image(@permissionService.admin_id, photo_path)
            end
        rescue Exception => e
            @logHandler.log_error("Send random photo (id: #{photo_id}, path: #{photo_path}) error: #{e}")
            @botResponseService.send_message(chat_id, ErrorMessages::EXCEPTION_OCCURRED)
        end
    end

    def viewed_all_photo?(user)
        viewed = @randPhotoRepository.get_viewed_count(user[DBFields::ID])
        count = @randPhotoRepository.get_photo_count
        return viewed == count
    end

    def get_stat(user)
        viewed = @randPhotoRepository.get_viewed_count(user[DBFields::ID])
        count = @randPhotoRepository.get_photo_count
        return count, viewed
    end

    def reset(user)
        chat_id = user[DBFields::TELEGRAM_CHAT_ID]
        user_id = user[DBFields::ID]

        if !@permissionService.can_execute_command?(user, DBConstValues::TRUSTED)
            @logHandler.log_info("User (chat id: #{chat_id}) does not have sufficient permissions to reset rand photos")
            @botResponseService.send_message(chat_id, ErrorMessages::INSUFFICIENT_PERMISSIONS)
            return
        end

        @randPhotoRepository.reset_user_save_path(user_id)
        @logHandler.log_info("User id: #{user_id} reset all rand photos")
        @botResponseService.send_message(chat_id, SuccessMessages::RESET_RAND_PHOTO)
    end
end