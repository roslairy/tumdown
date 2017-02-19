#################
# filename: data.coffee
# author: trollear
# date: 2017/2/18
#################

#################
# Preparation
#################

if not window.TD then window.TD = {}

#################
# Configs
#################

KEY = 'TD_DATA'

#################
# Data
#################

TD.data =
  storage: {}

  # create a new download and save to storage
  saveDownload: (id, name, url, state)->

    download =
      id: id
      name: name,
      url: url,
      state: state,

    @storage.downloads.push download

    # flush storage to localStorage
    @_flush()

  # delete a download with name
  deleteDownload: (name)->

    downloads = @storage.downloads

    for num in [0..downloads.length - 1]
      if downloads[num] isnt undefined and downloads[num].name is name

        # remove item
        downloads.splice num, 1
        break

    # flush storage to localStorage
    @_flush()

  # update download state with id
  updateDownload: (id, state)->

    @storage.downloads.forEach (elem, index, arr)->

      if elem and elem.id is id
        arr[index].state = state

    # flush storage to localStorage
    @_flush()

  # if download of particular name is already downloaded
  isDownloadExist: (name)->

    for download in @storage.downloads
      if download and download.name is name
        return true

    return false

  # return collection of downloading items
  getDownloadings: ()->

    @_reload()
    return @_getDownloadsOfState "downloading"

  # return collection of failed items
  getFaileds: ()->

    @_reload()
    return @_getDownloadsOfState "failed"

  # return collection of completed items
  getCompleteds: ()->

    @_reload()
    return @_getDownloadsOfState "completed"

  # save a pair of config to storage
  setConfig: (name, val)->

    @storage.configs[name] = val
    @_flush()

  # load value of key from storage
  getConfig: (name)->

    @_reload()
    @storage.configs[name]

  # return collection of particular state
  _getDownloadsOfState: (state)->

    downloads = []

    for download in @storage.downloads
      if download and download.state is state
        downloads.push download

    return downloads

  # flush storage to localStorage
  _flush: ()->
    window.localStorage.setItem KEY, JSON.stringify @storage

  # reload storage from localStorage
  _reload: ()->
    TD.data.storage = JSON.parse(window.localStorage.getItem(KEY)) || { configs: [], downloads: [] }

#################
# init
#################

# Check if localStorage is supported
if not window.localStorage
  console.error 'local storage is not supported.'
  return

# Ensure a valid storage
try
  TD.data.storage = JSON.parse(window.localStorage.getItem(KEY))
catch error
  TD.data.storage = null
finally
  if not TD.data.storage
    TD.data.storage = { configs: [], downloads: [] }

