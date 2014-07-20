async = require 'async'
read = require 'read'

phantom = page = credential = undefined

async.series [
  (callback) ->
    require('node-phantom').create (err, ph) ->
      phantom = ph
      callback(err, 'initializing PhantomJS')
  ,
  (callback) ->
    console.log 'Initializing PhantomJS...'
    phantom.createPage (err, pg) ->
      page = pg
      callback(err, 'initializing webpage')
  ,
  (callback) ->
    page.onUrlChanged = (targetUrl) ->
      console.log('Navigating to', targetUrl)

    page.onConsoleMessage = (msg, lineNum, sourceId) ->
      console.log '### JavaScript console: ' + msg

    console.log 'Opening the login page...'
    page.open 'https://quest.pecs.uwaterloo.ca/psp/SS', (err, status) ->
      unless err
        if status != 'success'
          err = 'failed openning login page'
      callback(err, 'opening login page')
  ,
  (callback) ->
    credentialFilename = require('path').join(__dirname, 'credential.yml')

    console.log 'Reading credential from', credentialFilename
    rawYaml = require('fs').readFileSync(credentialFilename, 'utf8')
    credential = require('js-yaml').safeLoad(rawYaml)

    if not credential.userid
      read prompt: 'Userid: ', (err, userid) ->
        credential.userid = userid
        callback(err, 'reading userid from file')
    else
      callback(null, 'reading userid from stdin')
  ,
  (callback) ->
    read prompt: 'Password: ', silent: true, (err, password) ->
      credential.password = password
      callback(err, 'getting password')
  ,
  (callback) ->
    console.log 'Logging in...'
    page.evaluate (credential) ->
      try
        document.getElementsByName("userid")[0].value = credential.userid
        document.getElementsByName("pwd")[0].value = credential.password
        document.getElementsByName("Submit")[0].click()
        null
      catch err
        err
    ,
    (err, evalErr) ->
      callback(err or evalErr, 'logging in')
    ,
    credential
  ,
  (callback) ->
    setTimeout ->
      # TODO PhantomJS crashes after 3 redirections.
      callback(null, 'waiting for redirection after login')
    ,
    15000
], (err, actions) ->
  if (err)
    [..., lastAction] = actions
    console.log 'Error when ' + lastAction + ':'
    console.log err
  phantom.exit()
