require 'ostruct'

module Namira
  ##
  # Builds a query
  #
  #   query = Namira::QueryBuilder.new
  #   query.name = 'Test Person'
  #   query.to_s
  #   => "name=Test%20Person"
  class QueryBuilder < OpenStruct
    ##
    # Returns the query as a valid query string
    #
    # @return [String]
    def to_s
      uri = Addressable::URI.new
      uri.query_values = to_h
      uri.query
    end
  end
end
