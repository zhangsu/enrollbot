fs = require 'fs'

casper = require('casper').create
  verbose: true
  waitTimeout: 60000
  logLevel: 'debug'

screenshotFilename = 'quest.png'
credential = {}
term = casper.cli.args[0]
term = 1 if term == undefined

fs.remove(screenshotFilename) if fs.exists(screenshotFilename)

casper.start 'https://quest.pecs.uwaterloo.ca/psp/SS'

formSelector = '#login'
casper.waitForSelector formSelector, ->
  readLine = require('system').stdin.readLine
  unless credential.userid
    credential.userid = readLine().trim()
  unless credential.password
    credential.password = readLine().trim()

  this.fill(formSelector, {
    userid: credential.userid,
    pwd: credential.password
  }, true)

iframeSelector = '#ptifrmtgtframe'
iframeName = 'TargetContent'

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    enrollLinkSelector = '#DERIVED_SSS_SCR_SSS_LINK_ANCHOR3'
    this.waitForSelector enrollLinkSelector, ->
      this.click enrollLinkSelector

continueButtonSelector = '#DERIVED_SSS_SCT_SSR_PB_GO'

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    addLabel = 'add'
    this.waitForText addLabel, ->
      this.clickLabel addLabel

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    this.waitForSelector continueButtonSelector, ->
      this.click("input[value='#{term}']")

casper.withFrame iframeName, ->
  this.clickLabel 'Continue'

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    proceedButtonLabel = 'Proceed to Step 2 of 3'
    this.waitForText proceedButtonLabel, ->
      this.clickLabel proceedButtonLabel

successful = false
errorIconSelector =
  'div[id^="win0divDERIVED_REGFRM1_SSR_STATUS_LONG"]' +
    ' img[src="/cs/SS/cache/85310/PS_CS_STATUS_ERROR_ICN_1.gif"]'
casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    finishButtonLabel = 'Finish Enrolling'
    this.waitForText finishButtonLabel, ->
      this.clickLabel finishButtonLabel

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    this.waitForSelector 'div[id^=win0divDERIVED_REGFRM1_SS_MESSAGE_LONG]', ->
      successful = not this.exists errorIconSelector

onComplete = ->
  this.capture screenshotFilename
  if successful
    this.echo "successfully enrolled!"
    this.exit(0)
  else
    this.echo 'Failed enrolling!'
    this.exit(1)

casper.onError = ->
  this.capture screenshotFilename

casper.run onComplete
