read = require 'read'
{spawn} = require 'child_process'

credential = {}

require('async').series [
  (callback) ->
    credentialFilename = require('path').join(__dirname, 'credential.yml')

    rawYaml = require('fs').readFileSync(credentialFilename, 'utf8')
    credential = require('js-yaml').safeLoad(rawYaml)

    if not credential.userid
      read prompt: 'Userid: ', (err, userid) ->
        credential.userid = userid
        callback(err, 'reading userid')
    else
      callback(null, 'reading userid')
  ,
  (callback) ->
    read prompt: 'Password: ', silent: true, (err, password) ->
      credential.password = password
      callback(err, 'reading password')
], (err, actions) ->
  if err
    [..., lastAction] = actions
    console.error 'Error when ' + lastAction + ':'
    console.error err
  else
    enroll = ->
      child = spawn 'node_modules/casperjs/bin/casperjs', ['enroll.coffee']

      child.stdin.write credential.userid + '\n'
      child.stdin.write credential.password + '\n'

      child.stdout.on 'data', (data) ->
        console.log data.toString()

      child.stderr.on 'data', (data) ->
        console.error data.toString()

      child.on 'close', (code) ->
        return if code == 0

        # Wait 20 min +/- a random number of mins < 5 before retrying.
        retryDelaySec = 20 * 60 + Math.random() * 10 * 60 - 5 * 60
        console.log 'Retrying in ' + retryDelaySec + ' seconds.'
        setTimeout ->
          enroll()
        ,
        retryDelaySec * 1000

    enroll()
