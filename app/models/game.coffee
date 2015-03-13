###
	Game model
		- create/modify game
		- access game info
		- access game's missions

###

#table constants

COL = 
	id: 'id'									#INT
	start_date: 'start_date'			#DATE
	end_date: 'end_date'					#DATE
	title: 'title'							#VARCHAR(45)
	description: 'description'			#TEXT(2000)
	visible: 'visible'					#BOOL
	
#Related tables, Foreign-This
TREL =
	users_in_games: 			app.models.C.TNAME.users_in_games			# user<-*->1 (intermediary)
	player_kill: 				app.models.C.TNAME.player_kill				# *->1
	mission: 					app.models.C.TNAME.mission						# *->1
	clarification_request: 	app.models.C.TNAME.clarification_request	# *->1
	geopoint:					app.models.C.TNAME.geopoint					# *->1
	geofence: 					app.models.C.TNAME.geofence					# *->1
	
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.game
	class app.models.Game
		constructor: ()->	
		
		#test example, TODO: remove this
		@getAll: ()->
			sql = 'SELECT '+COL.email+' FROM ' + TNAME
			
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					console.log "ROW: " + app.util.inspect row
			
			con.end()
			return
		
		# Creates a new game in the database.
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s) VALUES ("%s","%s","%s","%s",%i,%s,%s)'
			, [
				TNAME
				
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.visible
				
				data.start_date
				data.end_date
				data.title
				data.description
				if data.visible? then data.visible else false
			]
			
			#Basic sql call syntax here
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject()
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
		