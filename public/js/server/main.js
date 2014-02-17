(function() {
  var connectionHandler, express, expressApp, httpServer, logfmt, logger, port, socketIO, verbose;

  port = 4040;

  verbose = true;

  logfmt = require('logfmt');

  express = require('express');

  expressApp = express();

  httpServer = require('http').createServer(expressApp);

  socketIO = require('socket.io').listen(httpServer);

  logger = logfmt.requestLogger();

  expressApp.use(logger);

  expressApp.use(express["static"]("" + __dirname + "/../../public"));

  connectionHandler = require('./connectionHandler');

  socketIO.sockets.on('connection', function(socket) {
    return connectionHandler.onConnect(socket);
  });

  logfmt.log({
    port: port
  });

  httpServer.listen(port);

}).call(this);
