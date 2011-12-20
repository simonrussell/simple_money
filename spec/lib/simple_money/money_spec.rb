require 'spec_helper'

describe SimpleMoney::Money do

  let(:currency) { SimpleMoney::Currency.new(:name => 'Spec Currency', :iso_code => 'XYZ', :symbol => '$', :decimal_places => 2) }
  let(:money) { SimpleMoney::Money.new(currency, 123) }
  
  subject { SimpleMoney::Money }

  describe "simple" do
    before do
      SimpleMoney::Currency.stub!(:find => currency)
    end
  
    subject { SimpleMoney::Money.new(:XYZ, 123) }
    
    its(:currency) { should == currency }
    its(:currency_code) { should == currency.iso_code }
    its(:amount) { should == 123 }
    its(:amount_in_decimal) { should == "1.23" }
    
    it "should have iso-formatted to_s" do
      subject.to_s.should == subject.currency.format_value(subject.amount, :iso)
    end
  end
  
  describe "operators" do
    before do
      SimpleMoney::Currency.stub!(:find => currency)
    end
  
    before do
      @a = subject.new(:XYZ, 1000)
      @b = subject.new(:XYZ, 500)
      @c = subject.new(:XYZ, 0)
    end

    it "should support equality with other money" do
      @a.should == subject.new(@a.currency, @a.amount)
    end
    
    it "should support equality with zero" do
      @c.should == 0
    end

    describe "addition" do
      it "should support Money" do
        (@a + @b).should == subject.new(:XYZ, @a.amount + @b.amount)
      end
  
      it "should support 0" do
        (@a + 0).should == @a
      end
      
      it "should not allow random other stuff" do
        lambda { @a + "hello" }.should raise_error
      end 
    end
        
    describe "subtraction" do
      it "should support Money" do
        (@a - @b).should == subject.new(:XYZ, @a.amount - @b.amount)
      end
  
      it "should support 0" do
        (@a - 0).should == @a
      end
      
      it "should not allow random other stuff" do
        lambda { @a - "hello" }.should raise_error
      end 
    end
        
    it "should support multiplication with Numeric" do
      (@b * 2).should == @a
      (@b * 2.0).should == @a
    end
    
    it "should support division by a Money" do
      (@a / @b).should == 2
    end

  end
  
  describe "::from" do
  
    subject { SimpleMoney::Money.from(value) }
    
    context "with nil" do
      let(:value) { nil }
      it { should be_nil }
    end
    
    context "with blank string" do
      let(:value) { '' }
      it { should be_nil }
    end
    
    context "with Money" do
      let(:money) { SimpleMoney::Money.random }
      
      context "as Money" do
        let(:value) { money }
        it { should == money }
      end
      
      context "as iso String" do
        let(:value) { money.to_s }
        it { should == money }
      end
      
      context "as hash" do
        let(:value) do
          {
            'currency_code' => money.currency.iso_code,
            'amount_in_decimal' => money.currency.format_to_decimal(money.amount + 10_000_000, true)
          }  
        end
        
        it { should == money + SimpleMoney::Money.new(money.currency, 10_000_000) }
      end
      
      context "as hash with empty values" do
        let(:value) do
          {
            'currency_code' => '',
            'amount_in_decimal' => ''
          }  
        end
        
        it { should be_nil }
      end
      
      context "as hash with no currency, but default currency supplied" do
        subject { SimpleMoney::Money.from(value, :default_currency_code => money.currency.iso_code) }
      
        let(:value) do
          {
            'amount_in_decimal' => money.amount_in_decimal
          }
        end
        
        it { should == money }
      end
      
    end
    
  end
  
  describe "#to_s" do
    
    before do
      SimpleMoney::Currency.stub!(:find => currency)
    end
    
    let(:format) { mock }
    
    subject { money.to_s(format) }
    
    it "should call the currency with itself and the argument" do
      currency.should_receive(:format_value).with(money.amount, format)
      subject
    end    
    
  end
  
end
