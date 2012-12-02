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

@annotate = ($el, cl) ->
  if $el.length != 0
    # need to do this first or otherwise we get infinite recursion by creating
    # new non text children nodes
    annotate(nonTextNodes($el), cl)
    textNodes($el)
      .replaceWith( -> textWithClass(@textContent, cl))

@paragraph = $('#mw-content-text').find('p:first')

annotate(paragraph, 'dmitri')

@enumerate = ($el, cl1, cl2) ->
  num = 0
  $el.find(".#{ cl1 }").each( ->
    $(@).addClass("#{ cl2 }#{ num++ }")
  )

enumerate(paragraph, 'dmitri', 'number')

@highlightParagraph = ($el, cl, num) ->
  $e = $el.find(".#{ cl }#{ num }")
  if $e.length > 0 # when starting
    $e.css('background-color', 'white') # unset
  num++
  $e = $el.find(".#{ cl }#{ num }")
  if $e.length > 0
    $e.css('background-color', 'red')
    setTimeout(
      -> highlightParagraph($el, cl, num)
      1000
    )

highlightParagraph(paragraph, 'number', -1)
