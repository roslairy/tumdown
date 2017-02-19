#################
# filename: downloader.coffee
# author: trollear
# date: 2017/2/18
#################

#################
# Dom Sniff
#################

TD.downloader = {}

# Asynchronously load html page
TD.downloader._getUrl = (url, cb)->

  $.ajax({

    type: 'GET'
    url: url

    success: (data)->

      # parse html with zepto.js
      cb($ data, null, false)

    error: (xhr, type)->
      console.log 'GetUrl failed!'

  })

# sniff all tumblr image in url
TD.downloader._sniff = (url, cb)->

  @_getUrl url, (dom)->

    rawSrcs = []

    for img in dom.find('img')

      src = $(img).attr 'src'

      # collect srcs from *.media.tumblr.com
      # src containing 'avatar' and 'assets' is not post image
      if src.indexOf('avatar') is -1 and src.indexOf('assets') is -1 and src.indexOf('media.tumblr.com') isnt -1

        # fix resolution in url to get a better image
        tmp_url= src.replace(/_\d+\./, '_1280.')

        # extract image name from url
        name = tmp_url.slice(tmp_url.lastIndexOf('/') + 1)

        rawSrcs.push {
          name: name
          url: tmp_url
        }

    # callback
    cb(rawSrcs)

#################
# Downloader
#################

# Config key of download path
BASE_DL_PATH = "BASE_DL_PATH"

# default download path is "$DownloadDir/TDDir/"
TD.downloader.baseDLPath = TD.data.getConfig(BASE_DL_PATH) || "./TDDir/"

# download all post images of url
TD.downloader.download = (url)->

  @_sniff(url, (srcs)->

    for src in srcs

      DLPath = TD.downloader.baseDLPath + src.name

      # pass image if it's already downloaded
      if TD.data.isDownloadExist(src.name) then continue

      chrome.downloads.download(

        {
          url: src.url
          filename: DLPath
        }

        (downloadId)->

          # if fail to create download
          if downloadId is undefined
            TD.data.saveDownload downloadId, "failed", "failed", "failed"
            return

          # get download item with id
          chrome.downloads.search(

            {
              id: downloadId
            }

            (items)->

              # extract again due to closure bug
              tmp_url = items[0].url
              name = tmp_url.slice(tmp_url.lastIndexOf("/") + 1)
              TD.data.saveDownload items[0].id, name, tmp_url, "downloading"
          )
      )
  )

# load status of downloading downloads and update their status in data storage
TD.downloader.updateStatus = ()->

  for downloadObj in TD.data.getDownloadings()

    chrome.downloads.search(

      {
        id: downloadObj.id
      }

      (items)->

        # completed
        if items[0].state is 'complete'
          TD.data.updateDownload(items[0].id, 'completed')

        # failed
        else if items[0].state is 'interrupted'
          TD.data.updateDownload(items[0].id, 'failed')
    )

# Automatically update status of downloads
TD.downloader.autoUpdateStatus = ()->

  @updateStatus()

  # call itself in 1 second
  setTimeout(()=>
    @autoUpdateStatus()
  , 1000)

# Listen download request from content script and popup window
chrome.extension.onRequest.addListener (request, sender, sendResponse)->
    TD.downloader.download request.url

#################
# Init
#################

TD.downloader.autoUpdateStatus()