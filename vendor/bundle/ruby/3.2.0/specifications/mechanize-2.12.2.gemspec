# -*- encoding: utf-8 -*-
# stub: mechanize 2.12.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mechanize".freeze
  s.version = "2.12.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/sparklemotion/mechanize/issues", "changelog_uri" => "https://github.com/sparklemotion/mechanize/blob/main/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/mechanize", "homepage_uri" => "https://github.com/sparklemotion/mechanize", "source_code_uri" => "https://github.com/sparklemotion/mechanize", "yard.run" => "yard" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Hodel".freeze, "Aaron Patterson".freeze, "Mike Dalessio".freeze, "Akinori MUSHA".freeze, "Lee Jarvis".freeze]
  s.date = "2024-10-02"
  s.description = "The Mechanize library is used for automating interaction with websites.\nMechanize automatically stores and sends cookies, follows redirects,\nand can follow links and submit forms.  Form fields can be populated and\nsubmitted.  Mechanize also keeps track of the sites that you have visited as\na history.".freeze
  s.email = ["drbrain@segment7.net".freeze, "aaron.patterson@gmail.com".freeze, "mike.dalessio@gmail.com".freeze, "knu@idaemons.org".freeze, "ljjarvis@gmail.com".freeze]
  s.extra_rdoc_files = ["EXAMPLES.rdoc".freeze, "GUIDE.rdoc".freeze, "CHANGELOG.md".freeze, "README.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "EXAMPLES.rdoc".freeze, "GUIDE.rdoc".freeze, "README.md".freeze]
  s.homepage = "https://github.com/sparklemotion/mechanize".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.5.11".freeze
  s.summary = "The Mechanize library is used for automating interaction with websites".freeze

  s.installed_by_version = "3.5.23".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.8".freeze])
  s.add_runtime_dependency(%q<domain_name>.freeze, [">= 0.5.20190701".freeze, "~> 0.5".freeze])
  s.add_runtime_dependency(%q<http-cookie>.freeze, [">= 1.0.3".freeze, "~> 1.0".freeze])
  s.add_runtime_dependency(%q<mime-types>.freeze, ["~> 3.3".freeze])
  s.add_runtime_dependency(%q<net-http-digest_auth>.freeze, [">= 1.4.1".freeze, "~> 1.4".freeze])
  s.add_runtime_dependency(%q<net-http-persistent>.freeze, [">= 2.5.2".freeze, "< 5.0.dev".freeze])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.11.2".freeze, "~> 1.11".freeze])
  s.add_runtime_dependency(%q<webrick>.freeze, ["~> 1.7".freeze])
  s.add_runtime_dependency(%q<webrobots>.freeze, ["~> 0.1.2".freeze])
  s.add_runtime_dependency(%q<rubyntlm>.freeze, [">= 0.6.3".freeze, "~> 0.6".freeze])
  s.add_runtime_dependency(%q<base64>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<nkf>.freeze, [">= 0".freeze])
end
