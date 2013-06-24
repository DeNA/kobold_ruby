Gem::Specification.new do |s|
  s.name = 'rails_test_helpers'
  s.version = '0.0.2'
  s.date = '2013-05-20'
  s.summary = 'Rails test helpers'
  s.description = 'Rails test helpers'
  s.authors = ['Krieghan J. Riley']
  s.email = 'krieghan.riley@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.files.delete(".gitignore")
  s.add_dependency('rdouble')
  s.add_dependency('ruby_misc_helpers')
  s.add_dependency('ruby_test_helpers')
  s.require_paths = ["lib"]
end
