# -*- encoding: utf-8 -*-

module SimpleMoney
  class Currency
    
    CURRENCY_SPECS = {
      :AUD => { :name => 'Australian Dollar', :iso_code => 'AUD', :symbol => '$', :decimal_places => 2 },
      :USD => { :name => 'United States Dollar', :iso_code => 'USD', :symbol => '$', :decimal_places => 2 },
      :GBP => { :name => 'Pound Sterling', :iso_code => 'GBP', :symbol => '£', :decimal_places => 2 },
      :EUR => { :name => 'Euro', :iso_code => 'EUR', :symbol => '€', :decimal_places => 2 },
      :JPY => { :name => 'Japanese Yen', :iso_code => 'JPY', :symbol => '¥', :decimal_places => 0 }
    }
    
    VALID_REGEX = /\A(#{CURRENCY_SPECS.map { |k,v| k }.join('|')})\z/
    
    attr_reader :name, :iso_code, :symbol, :html_symbol, :decimal_places, :divisor, :decimal_regex
    
    def initialize(options)
      @name = options[:name].freeze
      @iso_code = options[:iso_code].freeze
      @symbol = options[:symbol].freeze
      @html_symbol = options[:html_symbol].freeze || @symbol
      
      @decimal_places = options[:decimal_places]
      @divisor = 10**@decimal_places
      
      @decimal_regex = @decimal_places > 0 ? /\A(\d+)(?:\.(\d{#{@decimal_places}}))?\Z/ : /\A(\d+)\Z/
      
      # unfortunately we can't freeze here because of the specs
    end
    
    def fractional?
      @decimal_places > 0
    end
    
    # sort of an internal method, used by format
    def format_to_decimal(value, nice = false, short = false)
      value = value.to_i
      
      sign = value < 0 ? '-' : ''
      whole = value.abs / @divisor
      fraction = value.abs % @divisor
      
      whole = nice_integer(whole) if nice
      
      sign + (fractional? && (!short || fraction > 0) ? "#{whole}.#{fraction.to_s.rjust(@decimal_places, '0')}" : whole.to_s)
    end
    
    def format_value(value, format_name)
      case format_name
      when :symbol
        "#{@symbol}#{format_to_decimal(value)}"
      when :nice_symbol
        "#{@symbol}#{format_to_decimal(value, true)}"
      when :short_symbol
        "#{@symbol}#{format_to_decimal(value, false, true)}"
      when :nice_short_symbol
        "#{@symbol}#{format_to_decimal(value, true, true)}"
      when :html
        "#{@html_symbol}#{format_to_decimal(value)}"
      when :nice_html
        "#{@html_symbol}#{format_to_decimal(value, true)}"
      when :short_html
        "#{@html_symbol}#{format_to_decimal(value, false, true)}"
      when :nice_short_html
        "#{@html_symbol}#{format_to_decimal(value, true, true)}"
      when :iso
        "#{@iso_code}#{format_to_decimal(value)}"
      else
        raise "unknown money format #{format_name}"
      end
    end
    
    def self.find(iso_code)
      return iso_code if iso_code.is_a?(Currency)
      return nil unless iso_code =~ VALID_REGEX
      
      iso_code = iso_code.to_sym
      
      @currency_singletons ||= Hash.new { |h, k| h[k] = new(CURRENCY_SPECS[k]).freeze if CURRENCY_SPECS.key?(k) }      
      @currency_singletons[iso_code]
    end
    
    def self.[](iso_code)
      find(iso_code)
    end
    
    def parse_from_decimal(string)
      raise DecimalFormatError.new("#{string.inspect}: invalid decimal") unless string =~ @decimal_regex
      
      result = $1.to_i * @divisor
      result += $2.ljust(@decimal_places, '0').to_i if $2
      result
    end
    
    private
    
    GROUPING_DIVISOR = 1000
    
    def nice_integer(value)
      return value.to_s if value < GROUPING_DIVISOR
      
      "#{nice_integer(value / GROUPING_DIVISOR)},#{(value % GROUPING_DIVISOR).to_s.rjust(3, '0')}"
    end
    
  end
end
