# Description:
#  It notifies the state of a test to ChatWork.
QS = require 'querystring'

module.exports = (robot) ->
  robot.hear /.*?(Fixed|Failed|Timed\sout)\sin\sbuild.*?/i, (msg) ->
    if /.*?Fixed.*?/.test(msg.message.text)
      prefix_body = "いつもありがとう！テストが直ったよ〜\n"
    else
      prefix_body = ''
      # テスト落ちた時に通知するChatWorkのユーザIDを指定
      to_ids = [365161, 774702, 580180]
      for id in to_ids
        prefix_body += "[To:#{id}]"

      prefix_body += "\nたいへん！テストが落ちたよ！\n"

    content = msg.message.text
    matches = /href="(.*?)"/.exec(content)

    if(matches?)
      content = content + "\n" + matches[1]


    body = prefix_body + "\n" + content
    body = body.replace(/<br \/>/g, "\n")
    body = body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, "")
    data = QS.stringify({'body': body})

    robot.http("https://api.chatwork.com/v1/rooms/#{process.env.CHATWORK_ROOM_ID}/messages")
    .headers('Content-Type': 'application/x-www-form-urlencoded', "X-ChatWorkToken": process.env.CHATWORK_API_TOKEN)
    .post(data) (err, r, body) ->

