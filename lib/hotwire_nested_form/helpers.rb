# frozen_string_literal: true

require_relative 'helpers/add_association'
require_relative 'helpers/remove_association'

module HotwireNestedForm
  module Helpers
    include AddAssociation
    include RemoveAssociation
  end
end
