module SimpleMoney
  class Money
    include Comparable
    
    attr_reader :currency, :amount
    
    def initialize(currency, amount)
      @currency = Currency.find(currency)
      @amount = amount
    end
    
    def amount_in_decimal
      @currency.format_to_decimal(@amount)
    end
     
    def to_s
      @currency.format_value(@amount, :iso)
    end
    
    def <=>(other)
      if other.eql?(0)    # it's exactly the integer zero
        @amount <=> 0
      elsif compatible_with?(other)
        @amount <=> other.amount
      else
        raise "can't compare Money with #{other}"
      end
    end
    
    def compatible_with?(other)
      other.is_a?(Money) && other.currency == @currency
    end
    
    def *(other)
      raise "can't multiply with #{other}" unless other.is_a?(Numeric)
      
      Money.new(@currency, (@amount * other).to_i)
    end
    
    def +(other)
      if other.eql?(0)
        self
      elsif compatible_with?(other)
        Money.new(@currency, @amount + other.amount)
      else
        raise "can't add with #{other}"
      end
    end
    
    def -(other)
      if other.eql?(0)
        self
      elsif compatible_with?(other)
        Money.new(@currency, @amount - other.amount)
      else
        raise "can't subtract with #{other}"
      end
    end
    
    def self.random(currencies = Currency::CURRENCY_SPECS.keys)
      currencies = [currencies] unless currencies.is_a?(Array)
      
      new(currencies.sample, rand(10000))
    end
  end
end
