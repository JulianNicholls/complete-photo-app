# Model of User:
#   Requires email confirmation
#   Has a single associated payment
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :payment
  accepts_nested_attributes_for :payment
end
