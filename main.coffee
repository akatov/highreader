@annotationClass = 'dmitri'
@highlightClass = 'dmitri_highlight'
@charsPerMinute = 1500
@minCharsPerHighlight = 15

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
  $el.find(".#{ cl }:visible").each( ->
    $(@).addClass("#{ cl }#{ num++ }")
  )
  $el.find(".#{ cl }").removeClass(cl)

# $el - paragraph
# cl  - selector class
# num - where we are currently looking
# agg - how many characters we have aggregated
#   (so we can set bigger timeout if necessary)
#
@highlightParagraphWords = ($el, cl, num) ->
  $el.find(".#{ highlightClass }").removeClass("#{ highlightClass }") # unset
  return unless num >= 0 # this finishes the callbacks
  agg = 0
  while agg < minCharsPerHighlight
    $e = $el.find(".#{ cl }#{ num++ }")
    if $e.length > 0
      $e.addClass(highlightClass)
      agg += $e.text().length
    else
      agg = minCharsPerHighlight # to finish while loop
      num = -1 # to finish callbacks
  setTimeout(
    -> highlightParagraphWords($el, cl, num)
    agg * 1000 * 60 / charsPerMinute
  )

@highlightParagraph = ($el) ->
  annotateParagraph($el, annotationClass)
  highlightParagraphWords(paragraph, annotationClass, 0)

@paragraph = $('#mw-content-text').find('p:first')

highlightParagraph(paragraph)
