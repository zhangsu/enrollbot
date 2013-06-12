require 'yaml'
require 'mechanize'

print 'Initializing... '

credential = YAML.load_file('credential.yaml')
login_url = 'https://quest.pecs.uwaterloo.ca/psp/SS/?cmd=login'
agent = Mechanize.new
agent.ca_file = 'curl-ca-bundle.crt'

puts 'Done.'
print 'Logging in... '

page = agent.get(login_url)
login_form = page.form('login')
%w(userid pwd).each { |field| login_form[field] = credential[field] }
page = login_form.submit

puts 'Done.'
puts 'Directing to enroll page... '

p page