require File.expand_path('../../simple_money.rb', __FILE__)

module SimpleMoney::ActiveRecord
  autoload :MoneyField, 'simple_money/active_record/money_field'
end

::ActiveRecord::Base.extend(SimpleMoney::ActiveRecord::MoneyField::ClassMethods)
