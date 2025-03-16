require 'redis'
require_relative 'redis_handler_base'

class RedisHandler < RedisHandlerBase
    def initialize(logHandler, settings, db_key)
        super(logHandler, settings, db_key)
    end

    def set_object(key, object, ttl = nil)
        begin
            if !redis_available?()
                return false
            end

            ttl ? @redis.setex(key, ttl, object) : @redis.set(key, object)            
            return true
        rescue StandardError => e
            @logHandler.log_error("Redis set_object error: #{e}")
            return false
        end
    end

    def get_object(key)
        begin
            if !redis_available?()
                return nil
            end

            value = @redis.get(key)
            return value ? value : nil            
        rescue StandardError => e
            @logHandler.log_error("Redis get_object error: #{e}")
            return nil
        end 
    end

    def delete(key)
        begin
            if !redis_available?()
                return false
            end

            @redis.del(key)
            return true
        rescue StandardError => e
            @logHandler.log_error("Redis delete error: #{e}")
            return false
        end
    end
end