fs = require 'fs'

casper = require('casper').create
  verbose: true
  waitTimeout: 60000
  logLevel: 'info'

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
      casper.log '[enrollbot] Clicking "Enroll"', 'info'
      this.click enrollLinkSelector

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    addLabel = 'add'
    tableRowSelector = '#win0divDERIVED_SSTSNAV_SSTS_NAV_SUBTABS'
    this.waitForSelector tableRowSelector, ->
      casper.log "[enrollbot] Clicking '#{addLabel}'", 'info'
      this.clickLabel addLabel

if term != 'null'
  casper.waitForSelector iframeSelector, ->
    this.withFrame iframeName, ->
      continueButtonSelector = '#DERIVED_SSS_SCT_SSR_PB_GO'
      this.waitForSelector continueButtonSelector, ->
        casper.log "[enrollbot] Choosing term #{term}", 'info'
        this.click("input[value='#{term}']")

  casper.withFrame iframeName, ->
    this.clickLabel 'Continue'

casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    proceedButtonLabel = 'Proceed to Step 2 of 3'
    this.waitForText proceedButtonLabel, ->
      casper.log "[enrollbot] Clicking #{proceedButtonLabel}", 'info'
      this.clickLabel proceedButtonLabel

successful = false
errorIconSelector =
  'div[id^="win0divDERIVED_REGFRM1_SSR_STATUS_LONG"]' +
    ' img[src="/cs/SS/cache/85310/PS_CS_STATUS_ERROR_ICN_1.gif"]'
casper.waitForSelector iframeSelector, ->
  this.withFrame iframeName, ->
    finishButtonLabel = 'Finish Enrolling'
    this.waitForText finishButtonLabel, ->
      casper.log "[enrollbot] Clicking '#{finishButtonLabel}'", 'info'
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
