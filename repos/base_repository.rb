class BaseRepository
    def get(key)
        raise NotImplementedError, "Must be implemented in #{self.class}"
    end

    def set(key, value)
        raise NotImplementedError, "Must be implemented in #{self.class}"
    end
end