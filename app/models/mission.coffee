###
	Mission Model 

###

#table constants

COL = 
	id: 'id'												#INT PK
	game_id: 'game_id'								#INT FK
	start_date: 'start_date'						#DATE
	end_date: 'end_date'								#DATE
	title: 'title'										#VARCHAR(45)
	description: 'description'						#TEXT(2000)
	succeeded: 'succeeded'							#BOOL
	visible_to_players: 'visible_to_players'	#BOOL
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.mission
	#Related tables, Foreign-This
	TREL = null
	class app.models.Mission
		constructor: ()->	
		
		# Creates a new mission in the database. Must have an accurate game_id
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s) VALUES (%i,"%s","%s","%s","%s",%i,%i)'
			, [
				TNAME
				
				COL.game_id
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.succeeded
				COL.visible_to_players
				
				data.game_id # MUST BE ACCURATE
				data.start_date
				data.end_date
				data.title
				data.description
				0 #false
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
			sql = app.vsprintf 'SELECT %s,%s,%s,%s,%s,%s,%s,%s FROM  %s'
			, [
				COL.id
				COL.game_id
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.succeeded
				COL.visible_to_players
				
				TNAME
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						missionId: row.id
						gameId: row.game_id
						startDate: row.start_date
						endDate: row.end_date
						title: row.title
						description: row.description
						succeeded: (parseInt row.succeeded) == 0
						visibleToPlayers: (parseInt row.visible_to_players) == 0
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
		