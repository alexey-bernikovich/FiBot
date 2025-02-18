class PermissionService    
    attr_accessor :admin_id

    def initialize(botUserService, settings)
        @botUserService = botUserService
        @admin_id = settings['admin_id']
    end

    def can_execute_command?(chat_id, required_role)
        user_role = @botUserService.get_user_role(chat_id).to_i
        return user_role >= required_role
    end

    def is_admin?(chat_id)
        user_role = @botUserService.get_user_role(chat_id).to_i
        return user_role == DBConstValues::ADMIN
    end
end