# Model for Stripe payment
class Payment < ActiveRecord::Base
  attr_accessor :card_number, :card_cvc, :card_expires_month, :card_expires_year

  belongs_to :user

  def self.month_options
    Date::MONTHNAMES.compact.each_with_index.map do |name, idx|
      month = idx + 1
      ["#{month} - #{name}", month]
    end
  end

  def self.year_options
    this_year = Date.today.year
    (this_year..(this_year + 10)).to_a
  end

  def process_payment
    customer = Stripe::Customer.create email: email, card: token

    Stripe::Charge.create customer:     customer.id,
                          amount:       1000,
                          description:  'Premium',
                          currency:     'gbp'
  end
end
