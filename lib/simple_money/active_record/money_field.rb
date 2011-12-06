module SimpleMoney

  module ActiveRecord::MoneyField
    module ClassMethods
      
      def money_field(name)
        cents_column = "#{name}_in_cents"
        currency_column = "#{name}_currency"
        
        class_eval "def #{name}
                      a = #{cents_column}   
                      a ? Money.new(#{currency_column}, a) : @#{name}
                    end"
                    
        class_eval "def #{name}=(money)
                      @#{name} = money
                      default_currency_code = #{currency_column}
                      money = ::SimpleMoney::Money.from(money, :default_currency_code => default_currency_code)
                      self.#{currency_column} = money && money.currency.iso_code
                      self.#{cents_column} = money && money.amount
                    end"
      end
      
    end    
  end

end
