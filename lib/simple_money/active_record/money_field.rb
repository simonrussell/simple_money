module SimpleMoney

  module ActiveRecord::MoneyField
    module ClassMethods
      
      def currency_field(name)
        currency_code_column = "#{name}_code"

        class_eval "def #{name}
                      Currency[#{currency_code_column}]
                    end"
                    
        class_eval "def #{name}=(currency)
                      self.#{currency_code_column} = (currency && currency.iso_code)
                    end"              
      end
      
      def money_field(name)
        cents_column = "#{name}_in_cents"
        currency_attr = "#{name}_currency"
        currency_code_column = "#{name}_currency_code"
        decimal_attr = "#{name}_in_decimal"
        
        class_eval "def #{name}
                      c = #{currency_attr}
                      a = #{cents_column}                   
                      Money.new(c, a) if c && a
                    end"
                    
        class_eval "def #{name}=(money)
                      remove_instance_variable(:@#{decimal_attr}) if instance_variable_defined?(:@#{decimal_attr})
                      self.#{currency_code_column} = (money && money.currency.iso_code)
                      self.#{cents_column} = (money && money.amount)
                    end"
                    
        currency_field(currency_attr)
        
        class_eval "def #{currency_code_column}=(code)
                      write_attribute(:#{currency_code_column}, code)
                      
                      if instance_variable_defined?(:@#{decimal_attr})
                        self.#{decimal_attr} = @#{decimal_attr}
                      end
                    end"
                    
        class_eval "def #{decimal_attr}
                      if instance_variable_defined?(:@#{decimal_attr})
                        @#{decimal_attr}
                      elsif #{name}
                        #{name}.amount_in_decimal
                      end
                    end"
                    
        class_eval "def #{decimal_attr}=(value)
                      @#{decimal_attr} = value
                      
                      self.#{cents_column} = (#{currency_attr} && #{currency_attr}.parse_from_decimal(value.to_s))
                      
                    rescue SimpleMoney::DecimalFormatError
                      self.#{cents_column} = nil
                    end"
                        
      end
      
      def fixed_currency_money_field(name, currency)
        cents_column = "#{name}_in_cents"
        currency_attr = "#{name}_currency"
        currency_code_column = "#{name}_currency_code"
        decimal_attr = "#{name}_in_decimal"
        
        class_eval "def #{name}
                      a = #{cents_column}                   
                      Money.new(#{currency_attr}, a) if a
                    end"
                    
        class_eval "def #{name}=(money)
                      remove_instance_variable(:@#{decimal_attr}) if instance_variable_defined?(:@#{decimal_attr})
                      return unless money.nil? || money.currency == #{currency_attr}
                      self.#{cents_column} = (money && money.amount)
                    end"
                    
        class_eval "def #{currency_attr}
                      Currency[#{currency_code_column}]
                    end"

        class_eval "def #{currency_code_column}
                      #{currency.iso_code.inspect}
                    end"
                    
        class_eval "def #{decimal_attr}
                      if instance_variable_defined?(:@#{decimal_attr})
                        @#{decimal_attr}
                      elsif #{name}
                        #{name}.amount_in_decimal
                      end
                    end"
                    
        class_eval "def #{decimal_attr}=(value)
                      @#{decimal_attr} = value
                      
                      self.#{cents_column} = (#{currency_attr} && #{currency_attr}.parse_from_decimal(value.to_s))
                      
                    rescue SimpleMoney::DecimalFormatError
                      self.#{cents_column} = nil
                    end"
                        
      end

    end    
  end

end
