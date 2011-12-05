require 'spec_helper'

describe SimpleMoney::Money do

  subject { SimpleMoney::Money }

  before do
    @currency = SimpleMoney::Currency.new(:name => 'Spec Currency', :iso_code => 'XYZ', :symbol => '$', :decimal_places => 2)
    SimpleMoney::Currency.stub!(:find).and_return(@currency)
  end

  describe "simple" do
    subject { SimpleMoney::Money.new(:XYZ, 123) }
    
    its(:currency) { should == @currency }
    its(:amount) { should == 123 }
    its(:amount_in_decimal) { should == "1.23" }
    
    it "should have iso-formatted to_s" do
      subject.to_s.should == subject.currency.format_value(subject.amount, :iso)
    end
  end
  
  describe "operators" do
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

  end
  
end
