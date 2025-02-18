require_relative '../data/constants'

class BotUserModel
    def initialize(database)
        @database = database
    end

    def find_user(chat_id)
        result = @database.query("SELECT * FROM #{DBTableNames::BOT_USER_TABLE} 
            WHERE #{DBFields::TELEGRAM_CHAT_ID} = #{chat_id}")
        return result.ntuples > 0 ? result.first : nil
    end

    def user_is_blocked(chat_id)
        user = find_user(chat_id)
        result = @database.query("SELECT * FROM #{DBTableNames::BLOCK_BOT_USER_TABLE}
            WHERE #{DBFields::BOT_USER_ID} = #{user[DBFields::ID]}")
        return result.ntuples > 0 ? true : false
    end

    def get_user_role(chat_id)
        result = @database.query("SELECT * FROM #{DBTableNames::BOT_USER_TABLE}
            WHERE #{DBFields::TELEGRAM_CHAT_ID} = #{chat_id}")
        return result.first[DBFields::BOT_USER_ROLE_ID]
    end

    def create_user(chat_id, first_name)
        @database.query_with_params("INSERT INTO #{DBTableNames::BOT_USER_TABLE} "\
        "(#{DBFields::TELEGRAM_CHAT_ID}, #{DBFields::FIRST_NAME}) VALUES ($1, $2)", [chat_id, first_name])
    end
end