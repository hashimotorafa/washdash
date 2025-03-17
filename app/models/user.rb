class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Associations
  belongs_to :company, optional: true

  # Enums
  enum role: {
    admin: 0,
    manager: 1,
    operator: 2
  }, status: {
    active: 0,
    inactive: 1
  }

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  def name
    "#{first_name} #{last_name}"
  end

  def active_for_authentication?
    super && active?
  end
end
