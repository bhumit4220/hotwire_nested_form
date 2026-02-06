# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :project
  has_many :subtasks, dependent: :destroy
  accepts_nested_attributes_for :subtasks, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  default_scope { order(:position) }
end
