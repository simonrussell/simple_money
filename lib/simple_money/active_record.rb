module SimpleMoney::ActiveRecord
  autoload :MoneyField, 'simple_money/active_record/money_field'
end

::ActiveRecord::Base.extend(SimpleMoney::ActiveRecord::MoneyField::ClassMethods)
