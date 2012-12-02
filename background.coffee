console.log "this is state"
console.log chrome.extension.getViews()
console.log chrome.extension.getBackgroundPage()

window.state = on
window.wpm = 300
window.wph = 3

chrome.extension.onRequest.addListener((request, sender, sendResponse) ->
  console.log request
  console.log sender
  console.log sendResponse
  if request.action == 'getState'
    sendResponse({state: window.state})
  else if request.action == 'setState'
    window.state = request.state
    sendResponse({})
  else if request.action == 'getWPM'
    sendResponse({wpm: window.wpm})
  else if request.action == 'setWPM'
    window.wpm = request.wpm
    sendResponse({})
  else if request.action == 'getWPH'
    sendResponse({wpm: window.wph})
  else if request.action == 'setWPH'
    window.wph = request.wph
    sendResponse({})
)
