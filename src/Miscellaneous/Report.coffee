Report =
  css: `<%= importCSS('noscript') %>`

  init: ->
    return unless /\bmode=report\b/.test(location.search) and match = location.search.match /\bno=(\d+)/
    Captcha.language.fixPage()
    @postID = +match[1]
    $.ready @ready

  ready: ->
    $.addStyle Report.css
    Report.archive() if Conf['Archive Report']
    if Conf['Use Recaptcha v2 in Reports']
      Report.captchaV2()
    if Conf['Use Recaptcha v2 in Reports'] and $.hasClass doc, 'js-enabled'
      new MutationObserver(-> Report.fit '.gc-bubbleDefault').observe d.body,
        childList:  true
        attributes: true
        subtree:    true
    else
      Report.fit 'body'

  captchaV2: ->
    return unless old = $.id 'captchaContainerAlt'
    container = $.el 'div',
      className: 'g-recaptcha'
    container.dataset.sitekey = '<%= meta.recaptchaKey %>'
    $.replace old, container
    url = 'https://www.google.com/recaptcha/api.js'
    if lang = Conf['captchaLanguage'].trim()
      url += "?hl=#{encodeURIComponent lang}"
    script = $.el 'script',
      src: url
    $.add d.head, script

  fit: (selector) ->
    return unless el = $ selector, doc
    dy = el.getBoundingClientRect().bottom - doc.clientHeight + 8
    window.resizeBy 0, dy if dy > 0

  archive: ->
    Redirect.init()
    return unless url = Redirect.to 'report', {boardID: g.BOARD.ID, postID: Report.postID}

    if (message = $ 'h3') and /Report submitted!/.test(message.textContent)
      if location.hash is '#redirect'
        $.globalEval 'self.close = function(){};'
        window.resizeBy 0, 350 - doc.clientHeight
        location.replace url
      return

    link = $.el 'a',
      href: url
      textContent: 'Report to archive'
    $.on link, 'click', (e) ->
      unless e.shiftKey or e.altKey or e.ctrlKey or e.metaKey or e.button isnt 0
        window.resizeBy 0, 350 - doc.clientHeight
    $.add d.body, [$.tn(' ['), link, $.tn(']')]

    if types = $.id('reportTypes')
      $.on types, 'change', (e) ->
        $('form').action = if e.target.value is 'illegal' then '#redirect' else ''
