require 'pg'

class Database
    def initialize(settings)
        @connection = PG.connect(dbname: settings['db_name'], user: settings['db_user'], 
            password: settings['db_password'])
    end

    def query(sql_query)
        return @connection.exec(sql_query)
    end

    def query_with_params(sql_query, params)
        return @connection.exec_params(sql_query, params)
    end
end