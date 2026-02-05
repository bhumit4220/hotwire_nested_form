# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :project

  validates :name, presence: true

  default_scope { order(:position) }
end
