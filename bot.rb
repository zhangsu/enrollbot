require 'mechanize'

login_url = 'https://quest.pecs.uwaterloo.ca/psp/SS/?cmd=login'

agent = Mechanize.new
agent.ca_file = 'curl-ca-bundle.crt'
page = agent.get(login_url)

p page.form('login')