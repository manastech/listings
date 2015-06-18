module ActiveRecord
  class QueryCounter
    cattr_accessor :query_count do
      0
    end

    IGNORED_SQL = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/]

    def call(name, start, finish, message_id, values)
      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      unless 'CACHE' == values[:name]
        self.class.query_count += 1 unless IGNORED_SQL.any? { |r| values[:sql] =~ r }
      end
    end
  end
end

ActiveSupport::Notifications.subscribe('sql.active_record', ActiveRecord::QueryCounter.new)

module ActiveRecord
  class Base
    def self.count_queries(&block)
      ActiveRecord::QueryCounter.query_count = 0
      yield
      ActiveRecord::QueryCounter.query_count
    end
  end
end
