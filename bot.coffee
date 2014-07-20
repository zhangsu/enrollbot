async = require 'async'

phantom = page = undefined

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
    console.log 'Opening the login page...'
    page.open 'https://quest.pecs.uwaterloo.ca/psp/SS', (err, status) ->
      unless err
        if status != 'success'
          err = 'failed openning login page'
      callback(err, 'opening login page')
  ,
  (callback) ->
    jsUrl = 'http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'
    page.includeJs jsUrl, (err) ->
      callback(err, 'including JQuery')
  ,
  (callback) ->
    page.evaluate ->
      $('input[value="Sign in"]')
    ,
    (err, result) ->
      console.log(result)

    callback(null, 'success')

], (err, results) ->
  if (err)
    console.log 'Error when', err
  phantom.exit()
