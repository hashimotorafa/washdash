# == Schema Information
#
# Table name: companies
#
#  id              :bigint           not null, primary key
#  name            :string
#  city            :string
#  state           :string
#  status          :integer          default("active")
#  document_number :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
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
