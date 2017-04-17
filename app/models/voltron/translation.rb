module Voltron
  class Translation < ActiveRecord::Base

    belongs_to :resource, polymorphic: true

  end
end