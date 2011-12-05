module SimpleMoney

  module ActiveRecord::MoneyField
    module ClassMethods
      
      def money_field(name)
        class_eval "def #{name}
                      a = #{name}_in_cents   
                      a && Money.new(#{name}_currency, a)
                    end"
      end
      
    end    
  end

end
