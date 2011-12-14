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
        
        attr_accessor :fish_price_currency_code
        attr_accessor :fish_price_in_cents
        
        def initialize(code, amount)
          @fish_price_currency_code = code
          @fish_price_in_cents = amount
        end
        
        def write_attribute(name, value)
          instance_variable_set("@#{name}", value)
        end
      end
    end
  
    let(:currency_code) { nil }
    let(:amount) { nil }
    let(:instance) { model_class.new(currency_code, amount) }
    
    subject { instance }
    
    it { should respond_to(:fish_price) }
    it { should respond_to(:fish_price=) }
    it { should respond_to(:fish_price_currency) }
    it { should respond_to(:fish_price_currency=) }
    it { should respond_to(:fish_price_in_decimal) }
    it { should respond_to(:fish_price_in_decimal=) }
  
    describe "#<name>" do
      
      subject { instance.fish_price }
      
      context "with not-nil currency and nil amount" do
        let(:currency_code) { SimpleMoney::Money.random.currency.iso_code }
        it { should be_nil }      
      end
      
      context "with not-nil currency and amount" do
        let(:money) { SimpleMoney::Money.random }
        let(:currency_code) { money.currency.iso_code }
        let(:amount) { money.amount }
        
        it { should be_a(SimpleMoney::Money) }
        
        it "should read the <name>_in_cents attribute" do
          instance.should_receive(:fish_price_in_cents).and_return(123)
          subject
        end

        it "should read the <name>_currency_code attribute" do
          instance.should_receive(:fish_price_currency_code).and_return(:USD)
          subject
        end
                
        it "should return the right Money" do
          should == money
        end
      end
    end
    
    describe "#<name>=" do
      subject { instance.fish_price = value }
      
      context "with nil" do
        let(:value) { nil }
        
        it "should set the currency to nil" do
          instance.should_receive(:fish_price_currency_code=).with(nil)
          subject
        end
        
        it "should set the amount to nil" do
          instance.should_receive(:fish_price_in_cents=).with(nil)
          subject
        end
        
        it "should reset the amount_in_decimal" do
          instance.fish_price_in_decimal = "asdf"
          subject
          instance.fish_price_in_decimal.should be_nil
        end
      end
    
      context "with a money" do
        let(:value) { SimpleMoney::Money.random }
        
        it "should set the currency" do
          instance.should_receive(:fish_price_currency_code=).with(value.currency.iso_code)
          subject
        end
        
        it "should set the amount" do
          instance.should_receive(:fish_price_in_cents=).with(value.amount)
          subject
        end
        
        it "should reset the amount_in_decimal" do
          instance.fish_price_in_decimal = "asdf"
          subject
          instance.fish_price_in_decimal.should == value.amount_in_decimal
        end        
      end
      
    end
    
    context "#<name>_currency" do
      subject { instance.fish_price_currency }
      
      context "with nil currency code" do
        it { should be_nil }
      end
      
      context "with valid currency code" do
        let(:currency_code) { 'AUD' }
        it { should == SimpleMoney::Currency[:AUD] }
      end
      
      context "with an invalid currency code" do
        let(:currency_code) { 'ZZZ' }
        it { should be_nil }
      end
    end
    
    context "#<name>_currency" do
      subject { instance.fish_price_currency = new_currency }
      
      context "with nil" do
        let(:new_currency) { nil }
        
        it "should set code to nil" do
          subject
          instance.fish_price_currency_code.should be_nil
        end
        
        it "should set amount_in_cents to nil if amount_in_decimal is set" do
          pending 
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

