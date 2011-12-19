require 'spec_helper'

describe SimpleMoney::Currency, 'class methods' do
  
  subject { SimpleMoney::Currency }
  
  it "should be able to find AUD from symbol" do
    subject.find(:AUD).iso_code.should == 'AUD'
  end
  
  it "should be able to find AUD from string" do
    subject.find('AUD').iso_code.should == 'AUD'
  end
  
  it "should be able to find AUD from AUD Currency object" do
    subject.find(subject.find(:AUD)).iso_code.should == 'AUD'
  end
  
  describe 'AUD' do
    subject { SimpleMoney::Currency.find(:AUD) }
  
    it { should be_frozen }
    
    it "should not create the same currency twice" do
      should == subject.class.find(:AUD)
    end
  end
    
end

describe SimpleMoney::Currency, 'instance methods' do
  
  CURRENCY_1_SPEC = { :name => 'Spec Dollar', :iso_code => 'XYZ', :symbol => '$', :html_symbol => '&pound;', :decimal_places => 3 }
  
  let(:currency) { SimpleMoney::Currency.new(CURRENCY_1_SPEC) }
  subject { currency }
  
  CURRENCY_1_SPEC.each do |k, v|
    its(k) { should == v }
    its(k) { should be_frozen } unless v.kind_of?(Fixnum)
  end
  
  it { should be_fractional }
  
  it "shouldn't be fractional when decimal_places == 0" do
    SimpleMoney::Currency.new(CURRENCY_1_SPEC.merge(:decimal_places => 0)).should_not be_fractional
  end
  
  its(:divisor) { should == 10**CURRENCY_1_SPEC[:decimal_places] }
  
  it "should use symbol when html symbol not supplied" do
    SimpleMoney::Currency.new(CURRENCY_1_SPEC.merge(:html_symbol => nil)).html_symbol.should == '$'
  end
  
  describe "decimal formatting" do
  
    describe "non fractional" do
      subject { SimpleMoney::Currency.new(CURRENCY_1_SPEC.merge(:decimal_places => 0)) }
      
      it "should not show decimal point" do
        subject.format_to_decimal(123456).should  ==  "123456"
        subject.format_to_decimal(0).should       ==       "0"
        subject.format_to_decimal(-123456).should == "-123456"
      end      

      it "should format nicely" do
        subject.format_to_decimal(123456, true).should  ==  "123,456"
        subject.format_to_decimal(0, true).should       ==        "0"
        subject.format_to_decimal(-123456, true).should == "-123,456"
      end
    end
    
    it "should support decimal formatting" do
      subject.format_to_decimal(123456789).should == "123456.789"
      subject.format_to_decimal(123456).should  ==  "123.456"
      subject.format_to_decimal(123056).should  ==  "123.056"
      subject.format_to_decimal(123006).should  ==  "123.006"
      subject.format_to_decimal(123000).should  ==  "123.000"
      subject.format_to_decimal(0).should       ==    "0.000"
      subject.format_to_decimal(-123456).should == "-123.456"
    end
    
    it "should support nice decimal formatting" do
      subject.format_to_decimal(1123456789, true).should == "1,123,456.789"
      subject.format_to_decimal(123456789, true).should  ==   "123,456.789"
      subject.format_to_decimal(23456789, true).should   ==    "23,456.789"
      subject.format_to_decimal(3456789, true).should    ==     "3,456.789"
      subject.format_to_decimal(456789, true).should     ==       "456.789"
      subject.format_to_decimal(56789, true).should      ==        "56.789"
      subject.format_to_decimal(1009096, true).should    ==     "1,009.096"
      subject.format_to_decimal(0, true).should          ==         "0.000"
    end
    
    it "should support short formatting" do
      subject.format_to_decimal(0, false, true).should == "0"
      subject.format_to_decimal(10, false, true).should == "0.010"
      subject.format_to_decimal(1000, false, true).should == "1"
      subject.format_to_decimal(1001, false, true).should == "1.001"
    end

  end
  
  describe "formatting" do
    
    [
      [:symbol, [], "$_"],
      [:nice_symbol, [true], "$_"],
      [:short_symbol, [false, true], "$_"],
      [:nice_short_symbol, [true, true], "$_"],
      [:html, [], "&pound;_"],
      [:nice_html, [true], "&pound;_"],
      [:short_html, [false, true], "&pound;_"],
      [:nice_short_html, [true, true], "&pound;_"],
      [:iso, [], "XYZ_"]
    ].each do |format_name, expected_args, result|
      it "should format #{format_name}" do
        subject.should_receive(:format_to_decimal).with(1234, *expected_args).and_return("_")
        subject.format_value(1234, format_name).should == result
      end
    end
    
  end
  
  describe "#parse_from_decimal" do
    
    {
      '123.006' => 123006,
      '123.056' => 123056,    
      '123.456' => 123456,
#      '123.45'  => 123450,
#      '123.4'   => 123400,
      '123'     => 123000
    }.each do |input, output|
      it "should parse #{input.inspect} to #{output}" do
        currency.parse_from_decimal(input).should == output
      end
    end
    
  end
  
end
