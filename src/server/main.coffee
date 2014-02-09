port       = 4040
verbose    = true

logfmt     = require('logfmt')
express    = require('express')
expressApp = express()
httpServer = require('http').createServer(expressApp)
socketIO   = require('socket.io').listen(httpServer)


expressApp.use logfmt.requestLogger()

expressApp.use express.static("#{__dirname}/../../public")

connectionHandler = require('./connectionHandler')

socketIO.sockets.on 'connection', (socket) -> connectionHandler.onConnect( socket )

httpServer.listen port