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
			sql = app.vsprintf 'SELECT createNewMission(%i,"%s","%s","%s","%s") AS mission_id'
			, [
				data.gameId # MUST BE ACCURATE
				data.title
				data.description
				data.startDate
				data.endDate
			]
			
			#Basic sql call syntax here
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					# Create roles_in_missions
					roleData = 
						missionId: parseInt row.mission_id
						roleIds: []
					
					if data.visibility.human
						roleData.roleIds.push app.hvz.roles.HUMAN.id
					if data.visibility.zombie
						roleData.roleIds.push app.hvz.roles.ZOMBIE.id
					if data.visibility.oz
						roleData.roleIds.push app.hvz.roles.OZ.id
						
					p = app.models.Roles.createNewRM roleData
					p.then ()->
						def.resolve()
					, (err)->
						def.reject err
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
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
		