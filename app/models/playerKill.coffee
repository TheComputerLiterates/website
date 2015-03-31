###
	Model for table player_kill.
	
	Handles in-game kills. 
	
###

COL =
	id: 'id'						# INT PK
	game_id: 'game_id'		# INT FK -> game.id
	killed_at: 'killed_at'	# DATETIME
	killer_id: 'killer_id'	# INT FK -> user.id
	victim_id: 'victim_id'	# INT FK -> user.id


module.exports = (app) ->
	TNAME = app.models.C.TNAME.player_kill
	
	#Related tables
	TREL = 
		user: 'user'
	
		
	class app.models.PlayerKill
		constructor: ()->
		
		@createNew: (killerId, victimHVZID)->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT %s(%i,%i) AS %s'
			, [
				app.models.C.RNAME.createPlayerKill
				
				killerId
				victimHVZID
				
				'result'
			]
			#Basic sql call syntax here
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					switch parseInt row.result
						when 0	#success
							def.resolve()
						when 1	#no human found with victimHVZID
							def.reject 'Invalid human HVZID'
						when 2	#no current game found
							def.reject 'No current game found' 
						else
							def.reject 'Problem saving kill'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
			con.end()
			
			return def.promise
		
		