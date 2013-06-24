Gem::Specification.new do |s|
  s.name = 'kobold'
  s.version = '0.0.1'
  s.date = '2013-06-24'
  s.summary = 'Helper modules for ruby development'
  s.description = 'Deep comparison, hash and list helpers, test helpers for rails and sinatra'
  s.authors = ['Krieghan J. Riley']
  s.email = 'krieghan.riley@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.files.delete(".gitignore")
  s.add_dependency('rdouble')
  s.require_paths = ["lib"]
end
