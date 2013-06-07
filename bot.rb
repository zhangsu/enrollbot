require 'yaml'
require 'mechanize'

credential = YAML.load_file('credential.yaml')

login_url = 'https://quest.pecs.uwaterloo.ca/psp/SS/?cmd=login'

agent = Mechanize.new
agent.ca_file = 'curl-ca-bundle.crt'
page = agent.get(login_url)

login_form = page.form('login')
%w(userid pwd).each { |field| login_form[field] = credential[field] }
p login_form.submit