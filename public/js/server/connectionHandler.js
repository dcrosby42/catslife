(function() {
  exports.onConnect = function(socket) {
    socket.emit('news', {
      hello: 'world'
    });
    return socket.on('my other event', function(data) {
      console.log(data);
      return console.log(data.my);
    });
  };

}).call(this);
