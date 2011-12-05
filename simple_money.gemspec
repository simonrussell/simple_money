Gem::Specification.new do |s|

  s.name = 'simple_money'
  s.version = '0.0.1'
  s.summary = 'Simple Money and Currency classes'
  s.description = <<-EOS
                    Money and Currency classes that make it pretty straightforward to get going on a multi-currency app.
                  EOS

  s.author = 'Simon Russell'
  s.email = 'spam+simple_money@bellyphant.com'
  s.homepage = 'http://github.com/simonrussell/simple_money'
  
  s.add_development_dependency 'autotest-standalone'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0.rc1'
  s.add_development_dependency 'nyan-cat-formatter'
  
  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
  
end
