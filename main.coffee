# @state = on
@annotationClass = 'dmitri'
@highlightClass = 'dmitri_highlight'
# @charsPerMinute = 1500
# @minCharsPerHighlight = 15
@minTimeout = 500

chrome.extension.sendRequest(action: 'getState', (response) =>
  @state = response.state || on
)
chrome.extension.sendRequest(action: 'getWPM', (response) =>
  @charsPerMinute = response.wpm * 5 || 1500
)
chrome.extension.sendRequest(action: 'getWPH', (response) =>
  @minCharsPerHighlight = response.wph * 5 || 15
)

$(->
  headHTML = document.getElementsByTagName('head')[0].innerHTML
  headHTML += "<style>.#{ highlightClass } { background-color: #FF9900; }</style>"
  document.getElementsByTagName('head')[0].innerHTML = headHTML
)

@wordWithClass = (word, cl='') ->
  "<span class='#{ cl }'>#{ word }</span>"

@textWithClass = (text, cl='') ->
  # console.log text
  # console.log text.split(' ')
  ret = (wordWithClass(word, cl) for word in text.split(' ')).join(' ')
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
# agg - how many characters we have aggregated
#   (so we can set bigger timeout if necessary)
#
@highlightParagraphWords = ($el, cl, num) ->
  $el.find(".#{ highlightClass }").removeClass("#{ highlightClass }") # unset
  if num < 0 # this finishes the callbacks
    $el.find(".#{ cl }").removeClass(cl)
    return
  agg = 0
  lastLeft = -10 # to keep track of line breaks
  while agg < minCharsPerHighlight
    $e = $el.find(".#{ cl }#{ num++ }")
    if $e.length > 0 && $e.position().left > lastLeft
      $e.addClass(highlightClass)
      agg += $e.text().length
      lastLeft = $e.position().left
    else if $e.length > 0 # linebreak
      num-- # so we display this again
      break
    else
      # agg = minCharsPerHighlight # to finish while loop
      num = -1 # to finish callbacks
      break
  timeout = Math.max(@minTimeout, agg * 1000 * 60 / charsPerMinute)
  setTimeout(
    -> highlightParagraphWords($el, cl, num)
    timeout
  )

@highlightParagraph = ($el) ->
  # try to stop first
  $e = $el.find(".#{ highlightClass }")
  if !@state || $e.length > 0 # if already highlighting
    deannotateParagraph($el, annotationClass)
  else # start highlighting
    annotateParagraph($el, annotationClass)
    highlightParagraphWords($el, annotationClass, 0)

@paragraphs = $('#mw-content-text').children()

@paragraphs.click( -> highlightParagraph($(@)))
