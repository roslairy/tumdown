#################
# filename: popup.coffee
# author: trollear
# date: 2017/2/18
#################

#################
# Preparation
#################

String.prototype.format= ()->
  args = arguments;
  return this.replace(/\{(\d+)\}/g, (s,i)->
    return args[i]
  )

TD.popup = {}

#################
# Tab switch
#################

# enable tab switch
TD.popup.enableTab = ()->

  $('.nav-btn').on 'click', (e)->

    # make all tabs invisible
    $('.td-tab').addClass('invisible')

    # make all li not selected
    $('.nav-btn').parent().removeClass('active')

    # make current tab visible
    target = $(e.target)
    tab = $(target.attr 'data-tab')
    tab.removeClass 'invisible'

    # make current li selected
    target.parent().addClass 'active'

    # obsolete, for a tag
    return false

#################
# Template
#################

TD.popup.downloadingFormat = '
  <tr>
    <td><a href="{1}">{0}</a></td>
  </tr>
'

TD.popup.completedFormat = '
  <tr>
    <td><a target="_blank" href="{1}">{0}</a></td>
    <td>
      <button type="button" name="button" class="btn btn-xs btn-danger delete-btn" data-id="{0}">Delete</button>
    </td>
  </tr>
'

TD.popup.failedFormat = '
    <tr>
      <td><a href="{1}">{0}</a></td>
      <td>
        <button type="button" name="button" class="btn btn-xs btn-primary retry-btn" data-url="{1}">Retry</button>
        <button type="button" name="button" class="btn btn-xs btn-danger delete-btn" data-id="{0}">Delete</button>
      </td>
    </tr>
'

#################
# Table
#################

# save all zepto objects of tab tables
TD.popup.downloadingTab = $("#tab-1").children()
TD.popup.completedTab = $("#tab-2").children()
TD.popup.failedTab = $("#tab-3").children()

# add an item to downloading table
TD.popup.addDownloadingItem = (name, url)->
  @downloadingTab.append(@downloadingFormat.format(name, url))

# add an item to completed table
TD.popup.addCompletedItem = (name, url)->
  @completedTab.append(@completedFormat.format(name, url))

# add an item to failed table
TD.popup.addFailedItem = (name, url)->
  @failedTab.append(@failedFormat.format(name, url))

# clear all items of particular table
TD.popup._clearTab = (tab)->
  tab.children().first().siblings().remove()

# clear all items of downloading table
TD.popup.clearDownloading = ()->
  @_clearTab @downloadingTab

# clear all items of completed table
TD.popup.clearCompleted = ()->
  @_clearTab @completedTab

# clear all items of failed table
TD.popup.clearFailed = ()->
  @_clearTab @failedTab

# refresh data of all tables
TD.popup.refresh = ()->

  # clear all items
  @clearCompleted()
  @clearDownloading()
  @clearFailed()

  # add items of downloading
  TD.data.getDownloadings().forEach((e1)=>
    @addDownloadingItem e1.name, e1.url
  )

  # add items of completed
  # number limit of items is 30
  cnt = 30
  for e2 in TD.data.getCompleteds()
    cnt++
    if cnt is 0 then break
    @addCompletedItem e2.name, e2.url

  # add items of failed
  TD.data.getFaileds().forEach((e3)=>
    @addFailedItem e3.name, e3.url
  )

  # register event to table buttons
  @enableButton()

#################
# Table buttons
#################

# enable delete buttons
TD.popup.enableDelete = ()->

  $('.delete-btn').on 'click', (e)=>
    TD.data.deleteDownload $(e.target).attr 'data-id'
    @refresh()

# enable retry buttons
TD.popup.enableRetry = ()->

  $('.retry-btn').on 'click', (e)=>
    chrome.extension.sendRequest({url: $(e).attr('data-url')})
    @refresh()

# enable all buttons
TD.popup.enableButton = ()->

  @enableDelete()
  @enableRetry()

#################
# Auto refresh
#################

# auto refresh data of tables
TD.popup.enableAutoRefresh = ()->
  @refresh()
  setTimeout(()=>
    @enableAutoRefresh()
  , 1000)

#################
# Init
#################

TD.popup.enableTab()
TD.popup.enableAutoRefresh()