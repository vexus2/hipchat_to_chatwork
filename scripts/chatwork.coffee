# Description:
#  It notifies the state of a test to ChatWork.
QS = require 'querystring'


failed_comments = [
  'たいへん！テストが落ちたよ！'
  'こらっ！テストが落ちたよ！'
  'テストガ オチマシタ'
  'テストが落ちたみたい。焦らなくていいから確認してね！'
  'テストが落ちたみたい。あきらめたらそこで試合終了だよ'
]
fixed_comments = [
  'いつもありがとう！テストが直ったよ〜'
  'テストが直ったけどべつに嬉しくなんかないんだからね！！'
]

Array::shuffle=->
    a=[@...]
    for i in [(a.length-1)..0] by -1
        p=(Math.random()*(i+1))|0
        [a[p],a[i]]=[a[i],a[p]]
    a

module.exports = (robot) ->
  robot.hear /.*?>\sclosed\s<.*?/, (msg) ->
    content = "Issuesが完了されたよー。かくにんしてね！"
    matches = /closed\s<a\shref="(.*?)"/.exec(msg.message.text)

    if(matches?)
      content = content + "\n" + matches[1]

    task_to_ids = [774699]
    data = QS.stringify({'body': content, 'to_ids': task_to_ids.toString()})

    robot.http("https://api.chatwork.com/v1/rooms/#{process.env.CHATWORK_TASK_ROOM_ID}/tasks")
    .headers('Content-Type': 'application/x-www-form-urlencoded', "X-ChatWorkToken": process.env.CHATWORK_API_TOKEN)
    .post(data) (err, r, body) ->

  robot.hear /.*?(Fixed|Failed|Timed\sout)\sin\sbuild.*?/i, (msg) ->
    if /.*?Fixed.*?/.test(msg.message.text)
      prefix_body = fixed_comments.shuffle()[0] + "\n"
    else
      prefix_body = ''
      # テスト落ちた時に通知するChatWorkのユーザIDを指定
      to_ids = [365161, 774702, 580180]
      for id in to_ids
        prefix_body += "[To:#{id}]"

      prefix_body += "\n" + failed_comments.shuffle()[0] + "\n"

    content = msg.message.text
    matches = /href="(.*?)"/.exec(content)

    if(matches?)
      content = content + "\n" + matches[1]


    body = prefix_body + "\n" + content
    body = body.replace(/<br \/>/g, "\n")
    body = body.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g, "")
    data = QS.stringify({'body': body})

    robot.http("https://api.chatwork.com/v1/rooms/#{process.env.CHATWORK_DEFAULT_ROOM_ID}/messages")
    .headers('Content-Type': 'application/x-www-form-urlencoded', "X-ChatWorkToken": process.env.CHATWORK_API_TOKEN)
    .post(data) (err, r, body) ->

