# frozen_string_literal: true

class Subtask < ApplicationRecord
  belongs_to :task

  validates :name, presence: true
end
