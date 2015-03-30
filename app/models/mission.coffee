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
	
	role_id: 'role_id'								#INT, TREL
	mission_id: 'mission_id'						#INT, TREL
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.mission
	#Related tables, Foreign-This
	TREL = 
		roles_in_missions: 'roles_in_missions'
		
	class app.models.Mission
		constructor: ()->	
		
		# Creates a new mission in the database. Must have an accurate game_id
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT createNewMission(%i,%i,"%s","%s","%s","%s") AS mission_id'
			, [
				data.gameId # MUST BE ACCURATE
				data.roleId # MUST BE ACCURATE
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
						startDate: app.moment(row.start_date)
						endDate: app.moment(row.end_date)
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
		
		# Returns all missions in a given game that a given role can see
		@getMissionsByGameRole: (gameId,roleId)->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT DISTINCT m.%s,m.%s,m.%s,m.%s,m.%s,m.%s,m.%s,m.%s FROM %s AS m ' +
				' INNER JOIN %s AS rm ON %s=%s' +
				' WHERE m.%s = %i' +
				(if roleId < app.hvz.roles.MODERATOR.id then ' AND rm.%s = %i' else '') +
				' ORDER BY m.'+COL.start_date+' DESC'
			, [
				COL.id
				COL.role_id
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.succeeded
				COL.visible_to_players
				
				TNAME
				TREL.roles_in_missions
				COL.id
				COL.mission_id
				
				COL.game_id
				gameId
				COL.role_id
				roleId
			]
			console.log 'SQL=['+sql+']'
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push
						missionId: parseInt row.id
						roleId: parseInt row.role_id
						startDate: app.moment(row.start_date)
						endDate: app.moment(row.end_date)
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
		
			
		