###
Main boot script, loading others and creates server.
###

#create express app
app = require('express')()

#configure app
require('./config')(app)

#set up routes 
require('./routes')(app)

#boot server
app.listen app.get('port'), ()->
	console.log 'Listening on port ' + app.get('port')