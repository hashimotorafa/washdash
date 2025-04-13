# == Schema Information
#
# Table name: external_accesses
#
#  id         :bigint           not null, primary key
#  email      :string
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint
#
class ExternalAccess < ApplicationRecord
  belongs_to :company
  # encrypts :password

  def has_credentials?
    password && email
  end
end
