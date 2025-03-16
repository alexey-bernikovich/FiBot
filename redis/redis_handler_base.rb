class RedisHandlerBase
    def initialize(logHandler, settings, db_key)
        @log_handler = logHandler
        @redis = Redis.new(host: settings["host"], port: settings["port"], db: db_key, timeout: 0.05)
    end

    protected
    def redis_available?()
        begin
            return @redis.ping == "PONG"
        rescue StandardError
            @log_handler.log_error("Redis is offline")
            return false
        end
    end

    def set_object(key, object, ttl = nil)
        raise NotImplementedError, "Must be implemented in #{self.class}"
    end

    def get_object(key)
        raise NotImplementedError, "Must be implemented in #{self.class}"
    end

    def delete(key)
        raise NotImplementedError, "Must be implemented in #{self.class}"
    end
end