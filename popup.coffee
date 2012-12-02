$(->
  console.log 'oh hai there'

  chrome.extension.sendRequest(action: 'getState', (response) ->
    $('#state').prop('checked', response.state || false)
  )

  $('#state').click( ->
    console.log 'clicked'
    chrome.extension.sendRequest({action: 'setState', state: $('#state').is(':checked')}, (response) ->
      console.log(response)
    )
  )

)
