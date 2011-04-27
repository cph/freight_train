class Money
  include Comparable
  attr_reader :amount, :currency
  EXCHANGE_RATES = { "USD_TO_DKK" => 6 }

  def initialize(amount, currency = "USD")
    @amount, @currency = amount, currency
  end

  def self.from_hash(hash)
    Money.new(hash[:amount].to_d, hash[:currency])
  end

  def exchange_to(other_currency)
    exchanged_amount = (amount * EXCHANGE_RATES["#{currency}_TO_#{other_currency}"]).floor
    Money.new(exchanged_amount, other_currency)
  end

  def ==(other_money)
    amount == other_money.amount && currency == other_money.currency
  end

  def <=>(other_money)
    if currency == other_money.currency
      amount <=> amount
    else
      amount <=> other_money.exchange_to(currency).amount
    end
  end
end