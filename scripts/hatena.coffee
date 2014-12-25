# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot hb <query> - The Original. Queries Hatena Bookmark for <query> and returns a random top result.
#   hubot <url> - Returns title, hatena bookmark entry url, and users for <url>.

cheerio = require 'cheerio'
request = require 'request'

module.exports = (robot) ->

  robot.respond /(https?:\/\/(\S+)\.(\S+))$/i, (msg) ->
    url = msg.match[1]
    apiurl = "http://b.hatena.ne.jp/entry/jsonlite/?url=" + encodeURIComponent(url)
    request apiurl, (_, res) ->
      json = JSON.parse(res.body)
      if json
        msg.send "#{json.title}\n#{json.count} users #{json.entry_url}"
      else
        request url, (_, res) ->
          $ = cheerio.load res.body
          msg.send $('title').text().replace(/\n/g, '')

  robot.respond /(hb|hatena) (\S+)( (\S+))?$/i, (msg) ->
    query = encodeURIComponent(msg.match[2])
    # tag or title or text
    target = msg.match[4] || 'tag'
    users = 5
    # recent or popular
    sort = 'recent'
    apiurl = "http://b.hatena.ne.jp/search/#{target}?q=#{query}&users=#{users}&sort=#{sort}"
    #msg.send apiurl
    request apiurl + '/', (_, res) ->
      $ = cheerio.load res.body
      sites = []
      count = 0
      $('#search-result-lists li').each ->
        li = $ @
        url = li.find('h3 a').attr('href')
        title = li.find('h3 a').attr('title')
        eurl = 'http://b.hatena.ne.jp' + li.find('span.users a').attr('href')
        users = li.find('span.users a').text()
        sites.push("#{title} #{url}\n#{users} #{eurl}")
        count++
        return false if count > 10
      msg.send msg.random sites

