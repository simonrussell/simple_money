require 'spec_helper'

module ActiveRecord
  class Base
  
  end
end

require 'simple_money/active_record'

describe SimpleMoney::ActiveRecord::MoneyField do
  
  describe "::money_field" do
  
    let(:model_class) do 
      Class.new do
        extend SimpleMoney::ActiveRecord::MoneyField::ClassMethods
        money_field :fish_price
        
        attr_accessor :fish_price_currency
        attr_accessor :fish_price_in_cents
      end
    end
  
    let(:instance) { model_class.new }
    
    subject { instance }
    
    it { should respond_to(:fish_price) }
  
    describe "#<name>" do
      
      subject { instance.fish_price }
      
      describe "with not-nil currency and nil amount" do

        before do
          instance.fish_price_currency = SimpleMoney::Money.random.currency.iso_code
          instance.fish_price_in_cents = nil
        end
        
        it { should be_nil }
      
      end
      
      describe "with not-nil currency and amount" do
        let(:money) { SimpleMoney::Money.random }
        
        before do
          instance.fish_price_currency = money.currency.iso_code
          instance.fish_price_in_cents = money.amount
        end
      
        it { should be_a(SimpleMoney::Money) }
      
        it "should read the <name>_in_cents attribute" do
          instance.should_receive(:fish_price_in_cents).and_return(123)
          subject
        end

        it "should read the <name>_currency attribute" do
          instance.should_receive(:fish_price_currency).and_return(:USD)
          subject
        end
                
        it "should return the right Money" do
          should == money
        end
      end
    end
  
  end

  describe "ActiveRecord::Base patch" do
    
    it "should patch onto ActiveRecord::Base" do
      ActiveRecord::Base.should respond_to(:money_field)
    end
    
  end

end

