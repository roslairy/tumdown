#################
# filename: content.coffee
# author: trollear
# date: 2017/2/18
#################

#################
# Preparation
#################

# Check if TD is existed
if not window.TD then window.TD = {}
TD.content = {}

# Append format to string
String.prototype.format= ()->
  args = arguments;
  return this.replace(/\{(\d+)\}/g, (s,i)->
    return args[i]
  )

#################
# Button
#################

# Due to extension baseUrl, fix background-image in css
TD.content.fixDivBGSrc = ()->

  realUrl = 'url({0})'.format(chrome.extension.getURL("img/btn.png"))
  $('div.TD-btn').css('background-image', realUrl)

# Template used to append button
TD.content.btnTemplate = '<div class="TD-btn" data-href="{0}"></div>'

# Obsolete, integrated to prependBtn
# Register click event to button
TD.content.enableBtns = ()->

  $('div.TD-btn').one 'click', (e)->

    target = $(e.target)
    href = target.attr 'data-href'
    target.addClass('clicked')

    # inform downloader to download url
    chrome.extension.sendRequest({url: href})

# Prepend button to every div.post and register event
TD.content.prependBtn = ()->

  $('html').find('div.post').forEach (elem)->

    elem = $ elem

    # if button is not added yet
    if not elem.children().first().hasClass('TD-btn')

      href = elem.find('a').attr('href') # get link to post page
      elem.prepend(TD.content.btnTemplate.format(href))

      # register event
      elem.children().first().one 'click', (e)->

        target = $(e.target)
        href = target.attr 'data-href'
        target.addClass('clicked')

        # inform downloader to download url
        chrome.extension.sendRequest({url: href})

  # fix background-image url
  @fixDivBGSrc()

# Automatically add button to newly loaded div.post
TD.content.enableReBtn = ()->

  @prependBtn()

  # run itself again in 1 second
  setTimeout(()=>
    @enableReBtn()
  , 1000)

#################
# Init
#################

TD.content.enableReBtn()