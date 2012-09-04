###
- Currently only supports data-target on the tabs, not href
###

$.fn.tabcordion = (option) ->
  return this.each ->
    $this = $(this)
    options = typeof option == 'object' && option
    data = $this.data('tabcordion') || new Tabcordion(this, options)
    if typeof option == 'string'
      data[option]()

$.fn.tabcordion.defaults =
  tabs:
    class: 'tabbable'
    listClass: 'nav nav-tabs'
    itemClass: ''
    bodyClass: 'tab-pane fade'
  accordion:
    class: 'accordion'
    listClass: 'nav'
    itemClass: 'accordion-group'
    bodyClass: 'accordion-body collapse'
  activeClass: 'active in'

class Tabcordion
  constructor: (el, options) ->
    @$el = $(el);
    @options = $.extend {}, $.fn.tabcordion.defaults, options
    # set up the initial tabbed state
    @$el.addClass(@options.tabs.class)
      .find('> .tab-content > *')
      .addClass(@options.tabs.bodyClass)
    @$el.find('> ul > li > a').attr('data-toggle', 'tab')
    @$el.data('tabcordion', this)
    if listClass = @$el.find('> ul').attr('class')
      @options.tabs.listClass += ' ' + listClass

  handleResize: ->

  tabs: ->
    if @$el.hasClass @options.tabs.class
      return
    @$el.removeClass(@options.accordion.class)
      .addClass(@options.tabs.class)
    
    $list = @$el.find('> ul')
      .removeClass(@options.accordion.listClass)
      .addClass(@options.tabs.listClass)
    $contentContainer = @$el.find('.tab-content')

    self = this
    $list.children()
      .removeClass(self.options.accordion.itemClass)
      .addClass(self.options.tabs.itemClass)
      .each ->
        $item = $(this)
        $link = $item.find('.accordion-heading a')
        $link.attr('data-toggle', 'tab')
        
        $content = $($link.attr('data-target'))
        
        $inner = $content.find('> .accordion-inner').remove()
        $content.append($inner.children())
        
        $item
          .children().remove().end()
          .append($link)

        $contentContainer.append($content)
        self.switchContent $link, $content, self.options.accordion, self.options.tabs
        true

  accordion: ->
    if @$el.hasClass @options.accordion.class
      return
    @$el.removeClass(@options.tabs.class)
      .addClass(@options.accordion.class)
    
    $list = @$el.find('> ul')
      .removeClass(@options.tabs.listClass)
      .addClass(@options.accordion.listClass)
    $contentContainer = @$el.find('.tab-content')
    
    self = this
    $items = $list.children()
    $items
      .removeClass(self.options.tabs.itemClass)
      .addClass(self.options.accordion.itemClass)
      .each ->
        $item = $(this)
        $link = $item.find('a')
        $content = $($link.attr('data-target'))
        
        $heading = $('<div class="accordion-heading" />').append($link);
        $content.append($('<div class="accordion-inner" />').append($content.children()))
        
        if !$content.attr 'id'
          $content.attr 'id', Tabcordion.generateId 'body'
        
        $link.addClass('accordion-toggle')
        $link.attr('data-toggle', 'collapse')
        $link.attr('data-target', '#' + $content.attr('id'))
        $link.data('parent', self.$el)

        $item.append($heading)
          .append($content)
        self.switchContent $link, $content, self.options.tabs, self.options.accordion
        true

  switchContent: ($link, $content, from, to) ->
    switchToTab = (to.bodyClass == @options.tabs.bodyClass)
    isActive = $content.hasClass('active')
    $content
      .removeClass(from.bodyClass)
      .addClass(to.bodyClass)
    if isActive
      $link.addClass @options.activeClass
      $content.addClass @options.activeClass
    else
      $link.removeClass @options.activeClass
      $content.removeClass @options.activeClass
    $content.collapse
      parent: @$el.find('> ul')
      toggle: false
    if switchToTab
      $content.data('collapse').reset(null)
    else
      $content.height if isActive then 'auto' else 0
      $content.collapse if isActive then 'show' else 'hide'
    return isActive

$.extend Tabcordion,
  idSuffix: 1
  generateId: (suffix) ->
    loop
      id = "tabcordion-#{suffix}-#{Tabcordion.idSuffix++}"
      break if $('#' + id).length == 0
    return id