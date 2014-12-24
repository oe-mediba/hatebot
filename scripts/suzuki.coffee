# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot szk|suzuki <query> - The Original. Queries Google Images for <鈴木 query> and returns a random top result.
#   hubot szk|suzuki g|gacha - The Original. Queries Google Images for <鈴木 オープンストリーム> and returns a random top result.
#   hubot szk|suzuki a|animate <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.

module.exports = (robot) ->

  robot.respond /(szk|suzuki) (g|gacha)$/i, (msg) ->
    #imageMe msg, 'オープンストリーム', false, true, (url) ->
    imageMe msg, 'オープンストリーム', (url) ->
      msg.send url

  robot.respond /(szk|suzuki) (a|animate) (.*)$/i, (msg) ->
    imageMe msg, msg.match[3], true, (url) ->
      msg.send url

  robot.respond /(szk|suzuki) (?!g|a)(.*)/i, (msg) ->
    
    imageMe msg, msg.match[3], (url) ->
      msg.send url

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: '鈴木 '+query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image = msg.random images
        cb ensureImageExtension image.unescapedUrl

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"
