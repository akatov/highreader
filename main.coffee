@annotationClass = 'dmitri'

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

@highlightParagraphWord = ($el, cl, num) ->
  $e = $el.find(".#{ cl }#{ num }")
  if $e.length > 0 # when starting
    $e.css('background-color', 'white') # unset
  num++
  $e = $el.find(".#{ cl }#{ num }")
  if $e.length > 0
    $e.css('background-color', 'red')
    setTimeout(
      -> highlightParagraphWord($el, cl, num)
      1000
    )

@highlightParagraph = ($el) ->
  annotateParagraph($el, annotationClass)
  highlightParagraphWord(paragraph, annotationClass, -1)

@paragraph = $('#mw-content-text').find('p:first')

highlightParagraph(paragraph)
