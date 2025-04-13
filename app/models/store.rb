# == Schema Information
#
# Table name: stores
#
#  id          :bigint           not null, primary key
#  name        :string
#  area_code   :string
#  external_id :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint
#  started_at  :date
#
class Store < ApplicationRecord
  # Associations
  belongs_to :company

  has_many :transactions
  has_many :cycles
  has_many :customers, through: :cycles
  has_many :income_statements
  # Validations
  validates :name, presence: true
  validates :area_code, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :company_id }
  validates :started_at, presence: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }
end
