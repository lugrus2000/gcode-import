# HTML 5 conformance checker
# 
# Warning: this module is experimental, incomplete, and subject to removal at any time.
# 
# Usage:
# >>> from html5lib.html5parser import HTMLParser
# >>> from html5lib.filters.validator import HTMLConformanceChecker
# >>> p = HTMLParser(tokenizer=HTMLConformanceChecker)
# >>> p.parse('<!doctype html>\n<html foo=bar></html>')
# <<class 'html5lib.treebuilders.simpletree.Document'> nil>
# >>> p.errors
# [((2, 14), 'unknown-attribute', {'attributeName' => u'foo', 'tagName' => u'html'})]

require 'html5/constants'
require 'html5/filters/base'
require 'html5/filters/iso639codes'
require 'html5/filters/rfc3987'
require 'html5/filters/rfc2046'

def _(str); str; end

HTML5::E.update({
  "unknown-start-tag" =>
    _("Unknown start tag <%(tagName)s>."),
  "unknown-attribute" =>
    _("Unknown '%(attributeName)s' attribute on <%(tagName)s>."),
  "missing-required-attribute" =>
    _("The '%(attributeName)s' attribute is required on <%(tagName)s>."),
  "unknown-input-type" =>
    _("Illegal value for attribute on <input type='%(inputType)s'>."),
  "attribute-not-allowed-on-this-input-type" =>
    _("The '%(attributeName)s' attribute is not allowed on <input type=%(inputType)s>."),
  "deprecated-attribute" =>
    _("This attribute is deprecated: '%(attributeName)s' attribute on <%(tagName)s>."),
  "duplicate-value-in-token-list" =>
    _("Duplicate value in token list: '%(attributeValue)s' in '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-attribute-value" =>
    _("Invalid attribute value: '%(attributeName)s' attribute on <%(tagName)s>."),
  "space-in-id" =>
    _("Whitespace is not allowed here: '%(attributeName)s' attribute on <%(tagName)s>."),
  "duplicate-id" =>
    _("This ID was already defined earlier: 'id' attribute on <%(tagName)s>."),
  "attribute-value-can-not-be-blank" =>
    _("This value can not be blank: '%(attributeName)s' attribute on <%(tagName)s>."),
  "id-does-not-exist" =>
    _("This value refers to a non-existent ID: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-enumerated-value" =>
    _("Value must be one of %(enumeratedValues)s: '%(attributeName)s' attribute on <%tagName)s>."),
  "invalid-boolean-value" =>
    _("Value must be one of %(enumeratedValues)s: '%(attributeName)s' attribute on <%tagName)s>."),
  "contextmenu-must-point-to-men" =>
    _("The contextmenu attribute must point to an ID defined on a <menu> element."),
  "invalid-lang-code" =>
    _("Invalid language code: '%(attributeName)s' attibute on <%(tagName)s>."),
  "invalid-integer-value" =>
    _("Value must be an integer: '%(attributeName)s' attribute on <%tagName)s>."),
  "invalid-root-namespace" =>
    _("Root namespace must be 'http://www.w3.org/1999/xhtml', or omitted."),
  "invalid-browsing-context" =>
    _("Value must be one of ('_self', '_parent', '_top'), or a name that does not start with '_' => '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-tag-uri" =>
    _("Invalid URI: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-urn" =>
    _("Invalid URN: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-uri-char" =>
    _("Illegal character in URI: '%(attributeName)s' attribute on <%(tagName)s>."),
  "uri-not-iri" =>
    _("Expected a URI but found an IRI: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-uri" =>
    _("Invalid URI: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-http-or-ftp-uri" =>
    _("Invalid URI: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-scheme" =>
    _("Unregistered URI scheme: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-rel" =>
    _("Invalid link relation: '%(attributeName)s' attribute on <%(tagName)s>."),
  "invalid-mime-type" =>
    _("Invalid MIME type: '%(attributeName)s' attribute on <%(tagName)s>."),
})


class HTMLConformanceChecker < HTML5::Filters::Base

  @@globalAttributes = ['class', 'contenteditable', 'contextmenu', 'dir',
    'draggable', 'id', 'irrelevant', 'lang', 'ref', 'tabindex', 'template', 
    'title', 'onabort', 'onbeforeunload', 'onblur', 'onchange', 'onclick',
    'oncontextmenu', 'ondblclick', 'ondrag', 'ondragend', 'ondragenter',
    'ondragleave', 'ondragover', 'ondragstart', 'ondrop', 'onerror', 
    'onfocus', 'onkeydown', 'onkeypress', 'onkeyup', 'onload', 'onmessage',
    'onmousedown', 'onmousemove', 'onmouseout', 'onmouseover', 'onmouseup',
    'onmousewheel', 'onresize', 'onscroll', 'onselect', 'onsubmit', 'onunload']
  # XXX lang in HTML only, xml:lang in XHTML only
  # XXX validate ref, template

  @@allowedAttributeMap = {
    'html' => ['xmlns'],
    'head' => [],
    'title' => [],
    'base' => ['href', 'target'],
    'link' => ['href', 'rel', 'media', 'hreflang', 'type'],
    'meta' => ['name', 'http-equiv', 'content', 'charset'], # XXX charset in HTML only
    'style' => ['media', 'type', 'scoped'],
    'body' => [],
    'section' => [],
    'nav' => [],
    'article' => [],
    'blockquote' => ['cite',],
    'aside' => [],
    'h1' => [],
    'h2' => [],
    'h3' => [],
    'h4' => [],
    'h5' => [],
    'h6' => [],
    'header' => [],
    'footer' => [],
    'address' => [],
    'p' => [],
    'hr' => [],
    'br' => [],
    'dialog' => [],
    'pre' => [],
    'ol' => ['start',],
    'ul' => [],
    'li' => ['value',], # XXX depends on parent
    'dl' => [],
    'dt' => [],
    'dd' => [],
    'a' => ['href', 'target', 'ping', 'rel', 'media', 'hreflang', 'type'],
    'q' => ['cite',],
    'cite' => [],
    'em' => [],
    'strong' => [],
    'small' => [],
    'm' => [],
    'dfn' => [],
    'abbr' => [],
    'time' => ['datetime',],
    'meter' => ['value', 'min', 'low', 'high', 'max', 'optimum'],
    'progress' => ['value', 'max'],
    'code' => [],
    'var' => [],
    'samp' => [],
    'kbd' => [],
    'sup' => [],
    'sub' => [],
    'span' => [],
    'i' => [],
    'b' => [],
    'bdo' => [],
    'ins' => ['cite', 'datetime'],
    'del' => ['cite', 'datetime'],
    'figure' => [],
    'img' => ['alt', 'src', 'usemap', 'ismap', 'height', 'width'], # XXX ismap depends on parent
    'iframe' => ['src',],
    # <embed> handled separately
    'object' => ['data', 'type', 'usemap', 'height', 'width'],
    'param' => ['name', 'value'],
    'video' => ['src', 'autoplay', 'start', 'loopstart', 'loopend', 'end',
          'loopcount', 'controls'],
    'audio' => ['src', 'autoplay', 'start', 'loopstart', 'loopend', 'end',
          'loopcount', 'controls'],
    'source' => ['src', 'type', 'media'],
    'canvas' => ['height', 'width'],
    'map' => [],
    'area' => ['alt', 'coords', 'shape', 'href', 'target', 'ping', 'rel',
         'media', 'hreflang', 'type'],
    'table' => [],
    'caption' => [],
    'colgroup' => ['span',], # XXX only if element contains no <col> elements
    'col' => ['span',],
    'tbody' => [],
    'thead' => [],
    'tfoot' => [],
    'tr' => [],
    'td' => ['colspan', 'rowspan'],
    'th' => ['colspan', 'rowspan', 'scope'],
    # all possible <input> attributes are listed here but <input> is really handled separately
    'input' => ['accept', 'accesskey', 'action', 'alt', 'autocomplete', 'autofocus', 'checked', 'disabled', 'enctype', 'form', 'inputmode', 'list', 'maxlength', 'method', 'min', 'max', 'name', 'pattern', 'step', 'readonly', 'replace', 'required', 'size', 'src', 'tabindex', 'target', 'template', 'value'],
    'form' => ['action', 'method', 'enctype', 'accept', 'name', 'onsubmit',
         'onreset', 'accept-charset', 'data', 'replace'],
    'button' => ['action', 'enctype', 'method', 'replace', 'template', 'name', 'value', 'type', 'disabled', 'form', 'autofocus'], # XXX may need matrix of acceptable attributes based on value of type attribute (like input)
    'select' => ['name', 'size', 'multiple', 'disabled', 'data', 'accesskey',
           'form', 'autofocus'],
    'optgroup' => ['disabled', 'label'],
    'option' => ['selected', 'disabled', 'label', 'value'],
    'textarea' => ['maxlength', 'name', 'rows', 'cols', 'disabled', 'readonly', 'required', 'form', 'autofocus', 'wrap', 'accept'],
    'label' => ['for', 'accesskey', 'form'],
    'fieldset' => ['disabled', 'form'],
    'output' => ['form', 'name', 'for', 'onforminput', 'onformchange'],
    'datalist' => ['data'],
  #  # XXX repetition model for repeating form controls
    'script' => ['src', 'defer', 'async', 'type'],
    'noscript' => [],
    'noembed' => [],
    'event-source' => ['src',],
    'details' => ['open',],
    'datagrid' => ['multiple', 'disabled'],
    'command' => ['type', 'label', 'icon', 'hidden', 'disabled', 'checked',
          'radiogroup', 'default'],
    'menu' => ['type', 'label', 'autosubmit'],
    'datatemplate' => [],
    'rule' => [],
    'nest' => [],
    'legend' => [],
    'div' => [],
    'font' => ['style',]
  }

  @@requiredAttributeMap = {
    'link' => ['href', 'rel'],
    'bdo' => ['dir',],
    'img' => ['src',],
    'embed' => ['src',],
    'object' => [], # XXX one of 'data' or 'type' is required
    'param' => ['name', 'value'],
    'source' => ['src',],
    'map' => ['id',]
  }

  @@inputTypeAllowedAttributeMap = {
    'text' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'inputmode', 'list', 'maxlength', 'name', 'pattern', 'readonly', 'required', 'size', 'tabindex', 'value'],
    'password' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'inputmode', 'maxlength', 'name', 'pattern', 'readonly', 'required', 'size', 'tabindex', 'value'],
    'checkbox' => ['accesskey', 'autofocus', 'checked', 'disabled', 'form', 'name', 'required', 'tabindex', 'value'],
    'radio' => ['accesskey', 'autofocus', 'checked', 'disabled', 'form', 'name', 'required', 'tabindex', 'value'],
    'button' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'value'],
    'submit' => ['accesskey', 'action', 'autofocus', 'disabled', 'enctype', 'form', 'method', 'name', 'replace', 'tabindex', 'target', 'value'],
    'reset' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'value'],
    'add' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'template', 'value'],
    'remove' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'value'],
    'move-up' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'value'],
    'move-down' => ['accesskey', 'autofocus', 'disabled', 'form', 'name', 'tabindex', 'value'],
    'file' => ['accept', 'accesskey', 'autofocus', 'disabled', 'form', 'min', 'max', 'name', 'required', 'tabindex'],
    'hidden' => ['disabled', 'form', 'name', 'value'],
    'image' => ['accesskey', 'action', 'alt', 'autofocus', 'disabled', 'enctype', 'form', 'method', 'name', 'replace', 'src', 'tabindex', 'target'],
    'datetime' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'datetime-local' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'date' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'month' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'week' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'time' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'number' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'range' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'list', 'min', 'max', 'name', 'step', 'readonly', 'required', 'tabindex', 'value'],
    'email' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'inputmode', 'list', 'maxlength', 'name', 'pattern', 'readonly', 'required', 'tabindex', 'value'],
    'url' => ['accesskey', 'autocomplete', 'autofocus', 'disabled', 'form', 'inputmode', 'list', 'maxlength', 'name', 'pattern', 'readonly', 'required', 'tabindex', 'value']
  }

  @@inputTypeDeprecatedAttributeMap = {
    'text'     => ['size'],
    'password' => ['size']
  }

  @@linkRelValues = ['alternate', 'archive', 'archives', 'author', 'contact', 'feed', 'first', 'begin', 'start', 'help', 'icon', 'index', 'top', 'contents', 'toc', 'last', 'end', 'license', 'copyright', 'next', 'pingback', 'prefetch', 'prev', 'previous', 'search', 'stylesheet', 'sidebar', 'tag', 'up']
  @@aRelValues    = ['alternate', 'archive', 'archives', 'author', 'contact', 'feed', 'first', 'begin', 'start', 'help', 'index', 'top', 'contents', 'toc', 'last', 'end', 'license', 'copyright', 'next', 'prev', 'previous', 'search', 'sidebar', 'tag', 'up', 'bookmark', 'external', 'nofollow']

  def initialize(stream, *args)
    super(HTML5::HTMLTokenizer.new(stream, *args))
    @thingsThatDefineAnID   = []
    @thingsThatPointToAnID  = []
    @IDsWeHaveKnownAndLoved = []
  end
  
  def each
    __getobj__.each do |token|
      fakeToken = {:type => token.fetch(:type, "-"),:name => token.fetch(:name, "-").capitalize}
      method = "validate#{token.fetch(:type, '-')}s#{token.fetch(:name, '-').capitalize}s"
      # p method
      if respond_to?(method)
        (send(method, token) || []).each{|t| yield t }
      else
        method = "validate#{token.fetch(:type, '-')}"
        # p method
        if respond_to?(method)
          send(method, token) do |t|
            yield t
          end
        end
      end
      yield token
    end
    for t in self.eof() or []
      yield t
    end
  end

  ##########################################################################
  # Start tag validation
  ##########################################################################

  def validateStartTag(token)
    checkUnknownStartTag(token){|t| p t; yield t}
    checkStartTagRequiredAttributes(token) do |t|
      yield t
    end
    checkStartTagUnknownAttributes(token) do |t|
      yield t
    end
    checkAttributeValues(token) do |t|
      yield t
    end
  end

  def validateStartTagEmbed(token)
    for t in checkStartTagRequiredAttributes(token) or []
      yield t
    end
    for t in checkAttributeValues(token) or []
      yield t
    end
    # spec says "any attributes w/o namespace"
    # so don't call checkStartTagUnknownAttributes
  end

  def validateStartTagInput(token)
    for t in checkAttributeValues(token) or []
      yield t
    end
    # attrDict = dict([(name.downcase, value) for name, value in token.fetch(:data, [])])
    inputType = attrDict.fetch(:type, "text")
    if !@@inputTypeAllowedAttributeMap.keys().include?(inputType)
      yield({:type => "ParseError",
           :data => "unknown-input-type",
           :datavars => {:attrValue => inputType}})
    end
    allowedAttributes = @@inputTypeAllowedAttributeMap.fetch(inputType, [])
    for attrName, attrValue in attrDict.items()
      if !@@allowedAttributeMap['input'].include?(attrName)
        yield({:type => "ParseError",
             :data => "unknown-attribute",
             :datavars => {"tagName" => "input",
                  "attributeName" => attrName}})
      elsif !allowedAttributes.include?(attrName)
        yield({:type => "ParseError",
             :data => "attribute-not-allowed-on-this-input-type",
             :datavars => {"attributeName" => attrName,
                  "inputType" => inputType}})
      end
      if inputTypeDeprecatedAttributeMap[inputType].include?(attrName)
        yield({:type => "ParseError",
             :data => "deprecated-attribute",
             :datavars => {"attributeName" => attrName,
                  "inputType" => inputType}})
      end
    end
  end
  ##########################################################################
  # Start tag validation helpers
  ##########################################################################

  def checkUnknownStartTag(token)
    # check for recognized tag name
    name = token.fetch(:name, "").downcase
    if !@@allowedAttributeMap.keys().include?(name)
      yield( {:type => "ParseError",
           :data => "unknown-start-tag",
           :datavars => {"tagName" => name}})
    end
  end

  def checkStartTagRequiredAttributes(token)
    # check for presence of required attributes
    name = token.fetch(:name, "").downcase
    if @@requiredAttributeMap.keys().include?(name)
      attrsPresent = token.fetch(:data, []).collect{|t| t[0]}
      for attrName in @@requiredAttributeMap[name]
        if !attrsPresent.include?(attrName)
          yield( {:type => "ParseError",
               :data => "missing-required-attribute",
               :datavars => {"tagName" => name,
                    "attributeName" => attrName}})
        end
      end
    end
  end

  def checkStartTagUnknownAttributes(token)
    # check for recognized attribute names
    name = token.fetch(:name).downcase
    allowedAttributes = @@globalAttributes | @@allowedAttributeMap.fetch(name, [])
    for attrName, attrValue in token.fetch(:data, [])
      if !allowedAttributes.include?(attrName.downcase())
        yield( {:type => "ParseError",
             :data => "unknown-attribute",
             :datavars => {"tagName" => name,
                  "attributeName" => attrName}})
      end
    end
  end

  ##########################################################################
  # Attribute validation helpers
  ##########################################################################

#  def checkURI(token, tagName, attrName, attrValue)
#    isValid, errorCode = rfc3987.isValidURI(attrValue)
#    if not isValid
#      yield {:type => "ParseError",
#           :data => errorCode,
#           :datavars => {"tagName" => tagName,
#                "attributeName" => attrName}}
#      yield {:type => "ParseError",
#           :data => "invalid-attribute-value",
#           :datavars => {"tagName" => tagName,
#                "attributeName" => attrName}}

  def checkIRI(token, tagName, attrName, attrValue)
    isValid, errorCode = rfc3987.isValidIRI(attrValue)
    if !isValid
      yield( {:type => "ParseError",
           :data => errorCode,
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
      yield( {:type => "ParseError",
           :data => "invalid-attribute-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  def checkID(token, tagName, attrName, attrValue)
    p :id
    if !attrValue
      yield( {:type => "ParseError",
           :data => "attribute-value-can-not-be-blank",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
    for c in attrValue
      if spaceCharacters.include?(c)
        yield( {:type => "ParseError",
             :data => "space-in-id",
             :datavars => {"tagName" => tagName,
                  "attributeName" => attrName}})
        yield( {:type => "ParseError",
             :data => "invalid-attribute-value",
             :datavars => {"tagName" => tagName,
                  "attributeName" => attrName}})
        break
      end
    end
  end

  def parseTokenList(value)
    valueList = []
    currentValue = ''
    for c in value + ' '
      if spaceCharacters.include?(c)
        if currentValue
          valueList.append(currentValue)
          currentValue = ''
        end
      else
        currentValue += c
      end
    end
    if currentValue
      valueList.append(currentValue)
    end
    valueList
  end
    
  def checkTokenList(tagName, attrName, attrValue)
    # The "token" in the method name refers to tokens in an attribute value
    # i.e. http://www.whatwg.org/specs/web-apps/current-work/#set-of
    # but the "token" parameter refers to the token generated from
    # HTMLTokenizer.  Sorry for the confusion.
    valueList = parseTokenList(attrValue)
    valueDict = {}
    for currentValue in valueList
      if valueDict.has_key(currentValue)
        yield( {:type => "ParseError",
             :data => "duplicate-value-in-token-list",
             :datavars => {"tagName" => tagName,
                  "attributeName" => attrName,
                  "attributeValue" => currentValue}})
        break
      end
      valueDict[currentValue] = 1
    end
  end

  def checkEnumeratedValue(token, tagName, attrName, attrValue, enumeratedValues)
    p :enum
    if !attrValue and (!enumeratedValues.include?(''))
      yield( {:type => "ParseError",
           :data => "attribute-value-can-not-be-blank",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
      return
    end
    attrValue = attrValue.downcase
    if !enumeratedValues.include?(attrValue)
      yield( {:type => "ParseError",
           :data => "invalid-enumerated-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName,
                "enumeratedValues" => tuple(enumeratedValues)}})
      yield( {:type => "ParseError",
           :data => "invalid-attribute-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  def checkBoolean(token, tagName, attrName, attrValue)
    enumeratedValues = [attrName, '']
    if !enumeratedValues.include?(attrValue)
      yield( {:type => "ParseError",
           :data => "invalid-boolean-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName,
                "enumeratedValues" => tuple(enumeratedValues)}})
      yield( {:type => "ParseError",
           :data => "invalid-attribute-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  def checkInteger(token, tagName, attrName, attrValue)
    sign = 1
    numberString = ''
    state = 'begin' # ('begin', 'initial-number', 'number', 'trailing-junk')
    error = {:type => "ParseError",
         :data => "invalid-integer-value",
         :datavars => {"tagName" => tagName,
                "attributeName" => attrName,
                "attributeValue" => attrValue}}
    attrValue.scan(/./) do |c|
      if state == 'begin'
        if HTML5::SPACE_CHARACTERS.include?(c)
          next
        elsif c == '-'
          sign  = -1
          state = 'initial-number'
        elsif HTML5::DIGITS.include?(c)
          numberString += c
          state = 'in-number'
        else
          yield error
          return
        end
      elsif state == 'initial-number'
        if !HTML5::DIGITS.include?(c)
          yield error
          return
        end
        numberString += c
        state = 'in-number'
      elsif state == 'in-number'
        if HTML5::DIGITS.include?(c)
          numberString += c
        else
          state = 'trailing-junk'
        end
      elsif state == 'trailing-junk'
        next
      end
    end
    if numberString.length == 0
      yield( {:type => "ParseError",
           :data => "attribute-value-can-not-be-blank",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  def checkFloatingPointNumber(token, tagName, attrName, attrValue)
    # XXX
    pass
  end

  def checkBrowsingContext(token, tagName, attrName, attrValue)
    return if not attrValue
    return if attrValue[0] != '_'
    attrValue = attrValue.downcase
    return if ['_self', '_parent', '_top', '_blank'].include?(attrValue)
    yield( {:type => "ParseError",
         :data => "invalid-browsing-context",
         :datavars => {"tagName" => tagName,
              "attributeName" => attrName}})
  end

  def checkLangCode(token, tagName, attrName, attrValue)
    return if !attrValue || attrValue == '' # blank is OK
    if not is_valid_lang_code(attrValue)
      yield( {:type => "ParseError",
           :data => "invalid-lang-code",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName,
                "attributeValue" => attrValue}})
    end
  end
  
  def checkMIMEType(token, tagName, attrName, attrValue)
    # XXX needs tests
    if not attrValue
      yield( {:type => "ParseError",
           :data => "attribute-value-can-not-be-blank",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
    if not rfc2046.isValidMIMEType(attrValue)
      yield( {:type => "ParseError",
           :data => "invalid-mime-type",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName,
                "attributeValue" => attrValue}})
    end
  end

  def checkMediaQuery(token, tagName, attrName, attrValue)
    # XXX
    pass
  end

  def checkLinkRelation(token, tagName, attrName, attrValue)
    for t in self.checkTokenList(tagName, attrName, attrValue) or []
      yield t
    end
    valueList = self.parseTokenList(attrValue)
    allowedValues = (tagName == 'link') and @@linkRelValues or @@aRelValues
    for currentValue in valueList
      if !allowedValues.include?(currentValue)
        yield({:type => "ParseError",
             :data => "invalid-rel",
             :datavars => {"tagName" => tagName,
                  "attributeName" => attrName}})
      end
    end
  end

  def checkDateTime(token, tagName, attrName, attrValue)
    # XXX
    state = 'begin' # ('begin', '...
#    for c in attrValue
#      if state == 'begin' =>
#        if spaceCharacters.include?(c)
#          continue
#        elsif digits.include?(c)
#          state = ...
  end

  ##########################################################################
  # Attribute validation
  ##########################################################################

  def checkAttributeValues(token)
    tagName = token.fetch(:name, "")
    fakeToken = {"tagName" => tagName.capitalize}
    for attrName, attrValue in token.fetch(:data, [])
      attrName = attrName.downcase
      fakeToken["attributeName"] = attrName.capitalize
      method = "validateAttributeValue#{fakeToken["tagName"]}s#{fakeToken["attributeName"]}s"

      if respond_to?(method)
        send(method, token, tagName, attrName, attrValue) do |t|
          yield t
        end
      else
        method = "validateAttributeValue#{fakeToken["attributeName"]}"
        if respond_to?(method)
          send(method, token, tagName, attrName, attrValue) do |t|
            yield t
          end
        end
      end
    end
  end

  def validateAttributeValueClass(token, tagName, attrName, attrValue)
    for t in self.checkTokenList(tagName, attrName, attrValue) or []
      yield t
      yield( {:type => "ParseError",
           :data => "invalid-attribute-value",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  def validateAttributeValueContenteditable(token, tagName, attrName, attrValue)
    for t in checkEnumeratedValue(token, tagName, attrName, attrValue, ['true', 'false', '']) or []
      yield t
    end
  end

  def validateAttributeValueDir(token, tagName, attrName, attrValue)
    for t in checkEnumeratedValue(token, tagName, attrName, attrValue, ['ltr', 'rtl']) or []
      yield t
    end
  end

  def validateAttributeValueDraggable(token, tagName, attrName, attrValue)
    for t in self.checkEnumeratedValue(token, tagName, attrName, attrValue, ['true', 'false']) or []
      yield t
    end
  end

  alias validateAttributeValueIrrelevant checkBoolean

  alias validateAttributeValueLang checkLangCode

  def validateAttributeValueContextmenu(token, tagName, attrName, attrValue)
    for t in checkID(token, tagName, attrName, attrValue) or []
      yield t
    end
    thingsThatPointToAnID.append(token)
  end

  def validateAttributeValueId(token, tagName, attrName, attrValue)
    # This method has side effects.  It adds 'token' to the list of
    # things that define an ID (self.thingsThatDefineAnID) so that we can
    # later check 1) whether an ID is duplicated, and 2) whether all the
    # things that point to something else by ID (like <label for> or
    # <span contextmenu>) point to an ID that actually exists somewhere.
    for t in checkID(token, tagName, attrName, attrValue) or []
      yield t
    end
    return if not attrValue
    if self.IDsWeHaveKnownAndLoved.include?(attrValue)
      yield( {:type => "ParseError",
           :data => "duplicate-id",
           :datavars => {"tagName" => tagName}})
    end
    IDsWeHaveKnownAndLoved.append(attrValue)
    thingsThatDefineAnID.append(token)
  end

  alias validateAttributeValueTabindex checkInteger

  def validateAttributeValueRef(token, tagName, attrName, attrValue)
    # XXX
    pass
  end

  def validateAttributeValueTemplate(token, tagName, attrName, attrValue)
    # XXX
    pass
  end

  def validateAttributeValueHtmlXmlns(token, tagName, attrName, attrValue)
    if attrValue != "http://www.w3.org/1999/xhtml"
      yield( {:type => "ParseError",
           :data => "invalid-root-namespace",
           :datavars => {"tagName" => tagName,
                "attributeName" => attrName}})
    end
  end

  alias validateAttributeValueBaseHref       checkIRI
  alias validateAttributeValueBaseTarget     checkBrowsingContext
  alias validateAttributeValueLinkHref       checkIRI
  alias validateAttributeValueLinkRel        checkLinkRelation
  alias validateAttributeValueLinkMedia      checkMediaQuery
  alias validateAttributeValueLinkHreflang   checkLangCode
  alias validateAttributeValueLinkType       checkMIMEType
  # XXX <meta> attributes
  alias validateAttributeValueStyleMedia     checkMediaQuery
  alias validateAttributeValueStyleType      checkMIMEType
  alias validateAttributeValueStyleScoped    checkBoolean
  alias validateAttributeValueBlockquoteCite checkIRI
  alias validateAttributeValueOlStart        checkInteger
  alias validateAttributeValueLiValue        checkInteger
  # XXX need tests from here on
  alias validateAttributeValueAHref          checkIRI
  alias validateAttributeValueATarget        checkBrowsingContext

  def validateAttributeValueAPing(token, tagName, attrName, attrValue)
    valueList = self.parseTokenList(attrValue)
    for currentValue in valueList
      for t in self.checkIRI(token, tagName, attrName, attrValue) or []
        yield t
      end
    end
  end

  alias validateAttributeValueARel           checkLinkRelation
  alias validateAttributeValueAMedia         checkMediaQuery
  alias validateAttributeValueAHreflang      checkLangCode
  alias validateAttributeValueAType          checkMIMEType
  alias validateAttributeValueQCite          checkIRI
  alias validateAttributeValueTimeDatetime   checkDateTime
  alias validateAttributeValueMeterValue     checkFloatingPointNumber
  alias validateAttributeValueMeterMin       checkFloatingPointNumber
  alias validateAttributeValueMeterLow       checkFloatingPointNumber
  alias validateAttributeValueMeterHigh      checkFloatingPointNumber
  alias validateAttributeValueMeterMax       checkFloatingPointNumber
  alias validateAttributeValueMeterOptimum   checkFloatingPointNumber
  alias validateAttributeValueProgressValue  checkFloatingPointNumber
  alias validateAttributeValueProgressMax    checkFloatingPointNumber
  alias validateAttributeValueInsCite        checkIRI
  alias validateAttributeValueInsDatetime    checkDateTime
  alias validateAttributeValueDelCite        checkIRI
  alias validateAttributeValueDelDatetime    checkDateTime

  ##########################################################################
  # Whole document validation (IDs, etc.)
  ##########################################################################

  def eof
    for token in @thingsThatPointToAnID
      tagName = token.fetch(:name, "").downcase
      attrsDict = token[:data] # by now html5parser has "normalized" the attrs list into a dict.
                    # hooray for obscure side effects!
      attrValue = attrsDict.fetch("contextmen", "")
      if attrValue and (!IDsWeHaveKnownAndLoved.include?(attrValue))
        yield( {:type => "ParseError",
             :data => "id-does-not-exist",
             :datavars => {"tagName" => tagName,
                  "attributeName" => "contextmen",
                  "attributeValue" => attrValue}})
      else
        for refToken in self.thingsThatDefineAnID
          id = refToken.fetch(:data, {}).fetch("id", "")
          if not id
            continue
          end
          if id == attrValue
            if refToken.fetch(:name, "").downcase != "men"
              yield( {:type => "ParseError",
                   :data => "contextmenu-must-point-to-men"})
            end
            break
          end
        end
      end
    end
  end
end