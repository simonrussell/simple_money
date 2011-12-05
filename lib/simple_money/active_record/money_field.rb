module SimpleMoney

  module ActiveRecord::MoneyField
    module ClassMethods
      
      def money_field(name)
        class_eval "def #{name}
                      a = #{name}_in_cents   
                      a && Money.new(#{name}_currency, a)
                    end"
                    
        class_eval "def #{name}=(money)
                      money = ::SimpleMoney::Money.from(money)
                      self.#{name}_currency = money && money.currency.iso_code
                      self.#{name}_in_cents = money && money.amount
                    end"
      end
      
    end    
  end

end
