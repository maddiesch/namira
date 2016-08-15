module Namira
  class QueryBuilder < OpenStruct
    def to_s
      to_h.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end
end
