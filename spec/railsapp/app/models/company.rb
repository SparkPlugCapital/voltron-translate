class Company < ActiveRecord::Base

  translates :name

  translates :greeting

  default_scope { joins(:translations).includes(:translations) }

end
