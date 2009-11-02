require File.dirname(__FILE__) + '/../../spec_helper'

describe Localise::Money do

  subject { Localise::Money }

  before do
    @currency = Localise::Currency.new(:name => 'Spec Currency', :iso_code => 'XYZ', :symbol => '$', :decimal_places => 2)
    Localise::Currency.stub!(:find).and_return(@currency)
  end

  describe "simple" do
    subject { Localise::Money.new(:XYZ, 123) }
    
    its(:currency) { should == @currency }
    its(:amount) { should == 123 }
    its(:amount_in_decimal) { should == "1.23" }
  end
  
  describe "operators" do
    before do
      @a = subject.new(:XYZ, 1000)
      @b = subject.new(:XYZ, 500)
    end

#    it "should support addition" do
#      (@a + @b).should == subject.new(:XYZ, @a.amount + @b.amount)
#    end
  end
  
end