# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot hb <query> - The Original. Queries Hatena Bookmark for <query> and returns a random top result.

cheerio = require 'cheerio'
request = require 'request'

module.exports = (robot) ->

  robot.respond /(hb|hatena) (.*)$/i, (msg) ->
    word = msg.match[2]
    url = "http://b.hatena.ne.jp/search/text?q=" + word
    request url + '/', (_, res) ->
      $ = cheerio.load res.body
      sites = []
      count = 0
      $('#search-result-lists li').each ->
        li = $ @
        url = li.find('h3 a').attr('href')
        title = li.find('h3 a').attr('title')
        burl = 'http://b.hatena.ne.jp' + li.find('span.users a').attr('href')
        users = li.find('span.users a').text()
        sites.push(title + " " + url + "\n" + users + " " + burl)
        count++
        return false if count > 5
      msg.send msg.random sites

