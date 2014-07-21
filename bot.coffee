read = require 'read'
{spawn} = require 'child_process'

argv = require('yargs')
  .alias(term: 't', 'base': 'b', 'var': 'v')
  .default(t: 1, b: 20, v: 5)
  .argv

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
      console.log 'term', argv.t
      console.log 'delay base', argv.b
      console.log 'delay variation', argv.v
      child = spawn 'node_modules/casperjs/bin/casperjs', [
        'enroll.coffee',
        argv.t
      ]

      child.stdin.write credential.userid + '\n'
      child.stdin.write credential.password + '\n'

      child.stdout.on 'data', (data) ->
        console.log data.toString()

      child.stderr.on 'data', (data) ->
        console.error data.toString()

      child.on 'close', (code) ->
        return if code == 0

        # Wait argv.b min +/- a random number of mins < argv.v.
        retryDelayMin = argv.b + Math.random() * 2 * argv.v - argv.v
        console.log 'Retrying in ' + retryDelayMin + ' mins.'
        setTimeout ->
          enroll()
        ,
        retryDelayMin * 60 * 1000

    enroll()
