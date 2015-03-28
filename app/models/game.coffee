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
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.game
	#Related tables, Foreign-This
	TREL =
		users_in_games: 			app.models.C.TNAME.users_in_games			# user<-*->1 (intermediary)
		player_kill: 				app.models.C.TNAME.player_kill				# *->1
		mission: 					app.models.C.TNAME.mission						# *->1
		clarification_request: 	app.models.C.TNAME.clarification_request	# *->1
		geopoint:					app.models.C.TNAME.geopoint					# *->1
		geofence: 					app.models.C.TNAME.geofence					# *->1
	
	
	class app.models.Game
		constructor: ()->	
		
		# Creates a new game in the database.
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s) VALUES ("%s","%s","%s","%s",%i)'
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
				0 #false
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
		
		@getAll: ()->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT %s,%s,%s,%s,%s,%s FROM  %s'
			, [
				COL.id
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.visible
				
				TNAME
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						gameId: row.id
						startDate: row.start_date
						endDate: row.end_date
						title: row.title
						description: row.description
						visible: (parseInt row.visible) == 0
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise