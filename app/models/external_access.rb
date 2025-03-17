# == Schema Information
# Schema version: 20240721001550
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
# Indexes
#
#  index_external_accesses_on_company_id  (company_id)
#
class ExternalAccess < ApplicationRecord
  belongs_to :company
  # encrypts :password

  def has_credentials?
    password && email
  end
end
