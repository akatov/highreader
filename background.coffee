@state = on
@wpm = 300
@wph = 3

@messageCurrentTab = (message) ->
  chrome.tabs.query({currentWindow: true, active: true }, (tabArray) ->
    console.log tabArray
    chrome.tabs.sendMessage(tabArray[0].id, message, ->)
  )

chrome.extension.onRequest.addListener((request, sender, sendResponse) =>
  console.log request
  if request.action == 'getState'
    sendResponse({state: @state})
  else if request.action == 'setState'
    @state = request.state
    @messageCurrentTab({action: 'setState', state: window.state})
    sendResponse({})
  else if request.action == 'getWPM'
    sendResponse({wpm: @wpm})
  else if request.action == 'setWPM'
    @wpm = request.wpm
    @messageCurrentTab({action: 'setWPM', wpm: window.wpm})
    sendResponse({})
  else if request.action == 'getWPH'
    sendResponse({wph: @wph})
  else if request.action == 'setWPH'
    @wph = request.wph
    @messageCurrentTab({action: 'setWPH', wph: window.wph})
    sendResponse({})
)
