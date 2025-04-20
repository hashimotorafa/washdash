class CustomerStore < ApplicationRecord
  belongs_to :customer
  belongs_to :store
end
