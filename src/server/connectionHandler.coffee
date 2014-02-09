
exports.onConnect = (socket) ->
  socket.emit 'news', { hello: 'world' }
  socket.on 'my other event', (data) ->
    console.log(data)
    console.log(data.my)
