class Store < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :name, presence: true
  validates :area_code, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :company_id }
  validates :started_at, presence: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }
end
