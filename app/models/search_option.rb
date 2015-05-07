class SearchOption < ActiveRecord::Base
    has_many :search_values

    def self.get_options
    	SearchOption.all
    end
end
