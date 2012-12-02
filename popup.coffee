$(->
  console.log 'oh hai there'

  chrome.extension.sendRequest(action: 'getState', (response) ->
    $('#state').prop('checked', response.state || false)
  )
  chrome.extension.sendRequest(action: 'getWPM', (response) ->
    $('#wpm').val(response.wpm)
  )
  chrome.extension.sendRequest(action: 'getWPH', (response) ->
    $('#wph').val(response.wph)
  )

  $('#state').click( ->
    console.log 'clicked'
    chrome.extension.sendRequest({action: 'setState', state: $('#state').is(':checked')}, (response) ->
      console.log(response)
    )
  )

  $('#ok').click( ->
    wpm = parseInt($('#wpm').val())
    wph = parseInt($('#wph').val())
    return if isNaN(wpm) || isNaN(wph) || wpm  == 0 || wph == 0
    chrome.extension.sendRequest({action: 'setWPM', wpm: wpm}, (response) ->
      console.log(response)
    )
    chrome.extension.sendRequest({action: 'setWPH', wph: wph}, (response) ->
      console.log(response)
    )
  )
)
