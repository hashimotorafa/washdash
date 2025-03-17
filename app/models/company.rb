class Company < ApplicationRecord
  # Enums
  enum status: {
    active: 0,
    inactive: 1
  }

  # Validations
  validates :name, presence: true
  validates :status, presence: true

  # Associations
  has_many :stores, dependent: :destroy
  has_many :users, dependent: :destroy
  has_one  :external_access, dependent: :destroy

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }
end
