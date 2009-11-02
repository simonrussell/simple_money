module Localise
  class Money
   
    attr_reader :currency, :amount
    
    def initialize(currency, amount)
      @currency = Currency.find(currency)
      @amount = amount
    end
    
    def amount_in_decimal
      @currency.format_to_decimal(@amount)
    end
            
  end
end