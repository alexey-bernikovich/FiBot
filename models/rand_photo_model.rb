require_relative '../data/constants'

class RandPhotoModel
    def initialize(database)
        @database = database
    end

    def get_viewed_count(user_id)
        result = @database.query("SELECT #{DBFuncNames::GET_VIEWED_COUNT}
            (#{user_id}, #{DBConstValues::FILE_TYPE_PHOTO})")
        return result.first[DBFuncNames::GET_VIEWED_COUNT].to_i
    end

    def get_photo_count
        result = @database.query("SELECT COUNT(*) FROM #{DBTableNames::FILE_PATH_TABLE}
            WHERE #{DBFields::FILE_TYPE_ID} = #{DBConstValues::FILE_TYPE_PHOTO} AND #{DBFields::IS_CENSORED} = false")
        return result.first['count'].to_i
    end

    def get_available(user_id)
        result = @database.query("SELECT #{DBFuncNames::GET_AVAILABLE_PATHS} (#{user_id}, #{DBConstValues::FILE_TYPE_PHOTO})")
        photo_ids = result.map { |row| row[DBFuncNames::GET_AVAILABLE_PATHS]}
        return photo_ids
    end

    def get_photo_by_id(photo_id)
        result = @database.query("SELECT * FROM #{DBTableNames::FILE_PATH_TABLE} WHERE #{DBFields::ID} = #{photo_id}")
        return result.first
    end

    def save_path(user_id, photo_id)
        result = @database.query("INSERT INTO #{DBTableNames::BOT_USER_PATH_SAVE} (#{DBFields::BOT_USER_ID}, 
            #{DBFields::FILE_PATH_ID}) VALUES (#{user_id}, #{photo_id})")
        return result
    end

    def reset_user_save_path(user_id)
        @database.query("CALL #{DBFuncNames::RESET_USER_SAVE_PATHS}(#{user_id}, #{DBConstValues::FILE_TYPE_PHOTO})")
    end
end