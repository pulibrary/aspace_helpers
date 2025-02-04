Re-run on CircleCI with ssh, put a byebug in the test before it fails (bundle exec rspec ./spec/reports/aspace2alma/get_MARCxml_spec.rb:107)

- If you want to do the nokogiri-diff, must edit gemfile to add gem 'nokogiri-diff', bundle install

```ruby
require 'nokogiri/diff' # only if you want to try using the diff

generated_xml = Nokogiri::XML(File.read(File.open(doc_file)))
fixture_xml = Nokogiri::XML(File.read(doc_after_processing_fixture))

fixture_xml.at_xpath('//marc:collection//marc:datafield[@tag="949"][1]')
generated_xml.at_xpath('//marc:collection//marc:datafield[@tag="949"][1]')

fixture_xml.at_xpath('//marc:collection//marc:datafield[@tag="949"][1]').diff(generated_xml.at_xpath('//marc:collection//marc:datafield[@tag="949"][1]')) { |change, node| puts "#{change} #{node.to_html}".ljust(30) + node.parent.path }
```
