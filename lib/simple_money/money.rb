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
    
    def currency_code
      @currency.iso_code
    end
     
    def to_s(format = :iso)
      @currency.format_value(@amount, format)
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
    
    def /(other)
      raise "can't divide by #{other}" unless other.is_a?(Money) && compatible_with?(other)
      
      @amount.to_f / other.amount
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
    
    def self.from(value, options = {})
      case value
      when Money
        value
      when nil, /\A\s*\Z/
        nil
      when /^([A-Z]{3})(\d+(?:\.\d+)?)$/
        currency = Currency.find($1)
        Money.new(currency, currency.parse_from_decimal($2))
      when Hash
        from_hash(value, options)
      else
        raise "#{value}: can't make Money from #{value.class}"
      end
    end
    
    private
    
    def self.from_hash(hash, options = {})
      currency_code = nil
      amount_in_decimal = nil
      
      hash.each do |key, value|
        case key
        when :currency_code, 'currency_code'
          currency_code = value.to_s
        when :amount_in_decimal, 'amount_in_decimal'
          amount_in_decimal = value.to_s
        end
      end
      
      currency_code = nil if currency_code =~ /\A\s*\Z/
      amount_in_decimal = nil if amount_in_decimal =~ /\A\s*\Z/
      
      currency_code ||= options[:default_currency_code]
      
      if currency_code && amount_in_decimal
        amount_in_decimal.gsub!(/[^a-z0-9\.]/, '')
        currency = Currency.find(currency_code)
        Money.new(currency, currency.parse_from_decimal(amount_in_decimal))
      end
    end
    
  end
end
