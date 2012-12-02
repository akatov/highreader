// Generated by CoffeeScript 1.4.0
(function() {
  var _this = this;

  this.annotationClass = 'dmitri';

  this.highlightClass = 'dmitri_highlight';

  this.lineTimeout = 600;

  chrome.extension.sendRequest({
    action: 'getState'
  }, function(response) {
    return _this.state = response.state || true;
  });

  chrome.extension.sendRequest({
    action: 'getWPM'
  }, function(response) {
    return _this.charsPerMinute = response.wpm * 5 || 1500;
  });

  chrome.extension.sendRequest({
    action: 'getWPH'
  }, function(response) {
    return _this.minCharsPerHighlight = response.wph * 5 || 15;
  });

  chrome.extension.onMessage.addListener(function(message, sender, sendResponse) {
    console.log(message);
    if (message.action === 'setState') {
      return _this.state = message.state;
    } else if (message.action === 'setWPM') {
      return _this.charsPerMinute = message.wpm * 5;
    } else if (message.action === 'setWPH') {
      return _this.minCharsPerHighlight = message.wph * 5;
    }
  });

  $(function() {
    var headHTML;
    headHTML = document.getElementsByTagName('head')[0].innerHTML;
    headHTML += "<style>." + highlightClass + " { background-color: #FF9900; }</style>";
    return document.getElementsByTagName('head')[0].innerHTML = headHTML;
  });

  this.wordWithClass = function(word, cl) {
    if (cl == null) {
      cl = '';
    }
    return "<span class='" + cl + "'>" + word + "</span>";
  };

  this.textWithClass = function(text, cl) {
    var ret, word;
    if (cl == null) {
      cl = '';
    }
    ret = ((function() {
      var _i, _len, _ref, _results;
      _ref = text.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        _results.push(wordWithClass(word, cl));
      }
      return _results;
    })()).join(' ');
    return ret;
  };

  this.textNodes = function($el) {
    return $el.contents().filter(function() {
      return this.nodeType === 3;
    });
  };

  this.nonTextNodes = function($el) {
    return $el.contents().filter(function() {
      return this.nodeType !== 3;
    });
  };

  this.preAnnotateParagraph = function($el, cl) {
    if ($el.length !== 0) {
      preAnnotateParagraph(nonTextNodes($el), cl);
      return textNodes($el).replaceWith(function() {
        return textWithClass(this.textContent, cl);
      });
    }
  };

  this.annotateParagraph = function($el, cl) {
    var num;
    preAnnotateParagraph($el, cl);
    num = 0;
    return $el.find("." + cl).each(function() {
      return $(this).addClass("" + cl + (num++));
    });
  };

  this.deannotateParagraph = function($el, cl) {
    var len, num, _i;
    len = $el.find("." + cl).length;
    for (num = _i = 0; 0 <= len ? _i < len : _i > len; num = 0 <= len ? ++_i : --_i) {
      $el.find("." + cl + num).removeClass("" + cl + num);
    }
    return $el.find("." + cl).removeClass(cl);
  };

  this.highlightParagraphWords = function($el, cl, num) {
    var $e, agg, lastLeft, linebreak, timeout;
    $el.find("." + highlightClass).removeClass("" + highlightClass);
    if (num < 0) {
      $el.find("." + cl).removeClass(cl);
      return;
    }
    agg = 0;
    lastLeft = -10;
    linebreak = false;
    while (agg < minCharsPerHighlight) {
      $e = $el.find("." + cl + (num++));
      if ($e.length > 0) {
        if (!$e.is(':visible')) {
          continue;
        }
        if ($e.position().left < lastLeft) {
          linebreak = true;
          break;
        }
        $e.addClass(highlightClass);
        agg += $e.text().length;
        lastLeft = $e.position().left;
      } else {
        num = -1;
        break;
      }
    }
    timeout = agg * 1000 * 60 / charsPerMinute;
    if (linebreak) {
      num--;
      timeout = Math.max(timeout, lineTimeout);
    }
    return setTimeout(function() {
      return highlightParagraphWords($el, cl, num);
    }, timeout);
  };

  this.highlightParagraph = function($el) {
    var $e;
    $e = $el.find("." + highlightClass);
    if (!this.state || $e.length > 0) {
      return deannotateParagraph($el, annotationClass);
    } else {
      annotateParagraph($el, annotationClass);
      return highlightParagraphWords($el, annotationClass, 0);
    }
  };

  this.paragraphs = $('#mw-content-text').children();

  this.paragraphs.click(function() {
    return highlightParagraph($(this));
  });

}).call(this);
