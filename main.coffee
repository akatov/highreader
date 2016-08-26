@myRND = Math.floor(Math.random() * 100)
@highlightClass = 'dmitri_highlight'
$(->
  headHTML = document.getElementsByTagName('head')[0].innerHTML
  headHTML += "<style>.#{ highlightClass } { background-color: #FFFF00; }</style>"
  document.getElementsByTagName('head')[0].innerHTML = headHTML
)
# x = document.createElement("style")
# x.innerText = "#{ highlightClass } { background-color: #FF9900; }"
# document.head.appendChild(x)

# x = document.createElement("script")
# x.src = 'https://static.firebase.com/v0/firebase.js'
# document.head.appendChild(x)

# y = document.createElement("script")
# y.innerHTML = 'document.Firebase = new Firebase("https://akatov.firebaseio.com")';
# document.head.appendChild(y)

@myDataRef = new Firebase('https://akatov.firebaseio.com/')
console.log @myDataRef

# @state = on
@annotationClass = 'dmitri'
# @charsPerMinute = 1500
# @minCharsPerHighlight = 15
@lineTimeout = 600

chrome.extension.sendRequest(action: 'getState', (response) =>
  @state = response.state || on
)
chrome.extension.sendRequest(action: 'getWPM', (response) =>
  @charsPerMinute = response.wpm * 5 || 1500
)
chrome.extension.sendRequest(action: 'getWPH', (response) =>
  @minCharsPerHighlight = response.wph * 5 || 15
)

chrome.extension.onMessage.addListener((message, sender, sendResponse) =>
  console.log message
  if message.action == 'setState'
    @state = message.state
  else if message.action == 'setWPM'
    @charsPerMinute = message.wpm * 5
  else if message.action == 'setWPH'
    @minCharsPerHighlight = message.wph * 5
)

@wordWithClass = (word, cl='') ->
  "<span class='#{ cl }'>#{ word } </span>"

@textWithClass = (text, cl='') ->
  # console.log text
  # console.log text.split(' ')
  ret = (wordWithClass(word, cl) for word in text.split(' ')).join('')
  # console.log ret
  ret

@textNodes = ($el) ->
  $el
    .contents()
    .filter( -> @nodeType == 3)

@nonTextNodes = ($el) ->
  $el
    .contents()
    .filter( -> @nodeType != 3)

@preAnnotateParagraph = ($el, cl) ->
  if $el.length != 0
    # need to do this first or otherwise we get infinite recursion by creating
    # new non text children nodes
    preAnnotateParagraph(nonTextNodes($el), cl)
    textNodes($el)
      .replaceWith( -> textWithClass(@textContent, cl))

@annotateParagraph = ($el, cl) ->
  preAnnotateParagraph($el, cl)
  num = 0
  $el.find(".#{ cl }").each( ->
    $(@).addClass("#{ cl }#{ num++ }")
  )

@deannotateParagraph = ($el, cl) ->
  len = $el.find(".#{ cl }").length
  for num in [0...len]
    $el.find(".#{ cl }#{ num }").removeClass("#{ cl }#{ num }")
  $el.find(".#{ cl }").removeClass(cl)

# $el - paragraph
# cl  - selector class
# num - where we are currently looking
#
@highlightParagraphWords = ($el, cl, num) =>
  $el.find(".#{ highlightClass }").removeClass("#{ highlightClass }") # unset
  if !@state || num < 0 # this finishes the callbacks
    deannotateParagraph($el, cl)
    return
  agg = 0
  lastLeft = -10 # to keep track of line breaks
  linebreak = false
  while agg < minCharsPerHighlight
    $e = $el.find(".#{ cl }#{ num++ }")
    if $e.length > 0
      continue unless $e.is(':visible')
      if $e.position().left < lastLeft # linebreak
        linebreak = true
        break
      $e.addClass(highlightClass)
      agg += $e.text().length
      lastLeft = $e.position().left
    else
      # agg = minCharsPerHighlight # to finish while loop
      num = -1 # to finish callbacks
      break
  timeout = agg * 1000 * 60 / charsPerMinute
  if linebreak
    num-- # so we display this again on next call
    timeout = Math.max(timeout, lineTimeout)
  setTimeout(
    -> highlightParagraphWords($el, cl, num)
    timeout
  )

@paragraphs = $('#mw-content-text').children()

@highlightParagraph = ($el, rnd) ->
  index = @paragraphs.index($el)
  # try to stop first
  $e = $el.find(".#{ highlightClass }")
  msg = {}
  if $e.length > 0 # if already highlighting
    msg = {rnd: @myRND, action: 'stop', el: index}
    deannotateParagraph($el, annotationClass)
  else # start highlighting
    msg = {rnd: @myRND, action: 'start', el: index}
    annotateParagraph($el, annotationClass)
    highlightParagraphWords($el, annotationClass, 0)
  console.log "rnd #{ rnd } myRND #{ @myRND }"
  if rnd == @myRND
    console.log "sending"
    console.log msg
    @myDataRef.push(msg)

@paragraphs.click( -> highlightParagraph($(@), myRND))

@myDataRef.on('child_added', (snapshot) ->
  message = snapshot.val()
  console.log "receiving"
  console.log message
  if message.rnd != @myRND && message.action == 'start' # only act on other's messages
    highlightParagraph($(@paragraphs[message.el]), message.rnd)
)
