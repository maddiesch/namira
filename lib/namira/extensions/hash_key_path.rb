module Namira
  module Extensions
    module HashKeyPath
      def value_for_key_path(path)
        components = path.split('.')
        value = self
        components.each do |key|
          break if value.nil?

          value = case value
                  when Hash
                    value[key] || value[key.to_sym]
                  when Array
                    value[key.to_i]
                  end
        end
        value
      end
    end
  end
end
