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

        user_from_db = @database.query("SELECT * FROM #{DBTableNames::BOT_USER_TABLE} 
            WHERE #{DBFields::TELEGRAM_CHAT_ID} = #{chat_id}")
        
        if user_from_db.ntuples > 0
            user = user_from_db.first

            is_blocked = @database.query("SELECT * FROM #{DBTableNames::BLOCK_BOT_USER_TABLE}
                WHERE #{DBFields::BOT_USER_ID} = #{user[DBFields::ID]}")
            
            if(is_blocked.ntuples > 0)
                user[DBFields::IS_BLOCKED] = true
                user[DBFields::IS_SHADOW] = is_blocked.first[DBFields::IS_SHADOW] == "t" ? true : false
            else
                user[DBFields::IS_BLOCKED] = false
            end

            @redis_client.set_object(chat_id, user)
            return user
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
end