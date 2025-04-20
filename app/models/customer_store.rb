# == Schema Information
#
# Table name: customer_stores
#
#  id               :bigint           not null, primary key
#  customer_id      :bigint           not null
#  store_id         :bigint           not null
#  first_visit_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class CustomerStore < ApplicationRecord
  belongs_to :customer
  belongs_to :store
end
