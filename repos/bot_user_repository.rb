require_relative 'base_repository'
require_relative '../data/constants'

class BotUserRepository < BaseRepository
    def initialize(log_handler, database, redis_client)
        @log_handler = log_handler
        @database = database
        @redis_client = redis_client
    end

    def get(chat_id)
        user = @redis_client.get_object(chat_id)
        if user != nil
            return user
        end

        result = @database.query("SELECT * FROM #{DBTableNames::BOT_USER_TABLE} 
            WHERE #{DBFields::TELEGRAM_CHAT_ID} = #{chat_id}")
        
        if result.ntuples > 0
            @redis_client.set_object(chat_id, result.first)
            return result.first
        else
            return nil
        end        
    end

    def set(chat_id, first_name)
        @database.query_with_params("INSERT INTO #{DBTableNames::BOT_USER_TABLE} "\
            "(#{DBFields::TELEGRAM_CHAT_ID}, #{DBFields::FIRST_NAME}) VALUES ($1, $2)", [chat_id, first_name])
        created_user = get(chat_id)

        if created_user != nil
            @redis_client.set_object(chat_id, created_user)
            return created_user
        else
            return nil
        end
    end

    def user_is_blocked?(user_id)
        result = @database.query("SELECT * FROM #{DBTableNames::BLOCK_BOT_USER_TABLE}
            WHERE #{DBFields::BOT_USER_ID} = #{user_id}")
        return result.ntuples > 0 ? true : false
    end
end