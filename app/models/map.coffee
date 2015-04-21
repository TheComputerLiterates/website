###
	Handles map elements
		- geofence
		- geopoint
###

TRIGGER_RATE = 1 #per second

TNAME = 
	geopoint: 'geopoint'
	geofence: 'geofence'
	roles_affecting_geofences: 'roles_affecting_geofences'
	roles_seeing_geopoints: 'roles_seeing_geopoints'

COL = 
	id: 'id'
	geopoint_id: 'id'
	game_id: 'game_id'
	mission_id: 'mission_id'
	description: 'description'
	trigger_rate: 'trigger_rate'
	visible: 'visible'
	score: 'score'
	triggers_on: 'triggers_on'
	color: 'color'
	
	source_user_id: 'source_user_id'
	longitude: 'longitude'
	latitude: 'latitude'
	visible: 'visible'
	player: 'player'
	
	role_id: 'role_id'
	geofence_id: 'geofence_id'
	score_modifier: 'score_modifier'
	triggers: 'triggers'
	
module.exports = (app) ->
	class app.models.Map
		constructor: ()->	
		
		# Creates a new game in the database. Also creates RoGs w/ trigger
		@createNewGeofence: (data) ->
			# console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) '+
				'VALUES (%i,%i,%f,%f,"%s",%i,%i,%i,%i,%i)'
			, [
				TNAME.geofence
				
				COL.game_id
				COL.mission_id
				COL.latitude
				COL.longitude
				COL.description
				COL.trigger_rate
				COL.visible
				COL.score
				COL.triggers_on
				COL.color
				
				data.gameId
				data.missionId
				data.latitude
				data.longitude
				data.description
				TRIGGER_RATE
				1
				0
				1
				data.color
			]
			# console.log sql
			
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
		
		@updateRolesGeofences: (data)->
			console.log 'STARTED ' + app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'UPDATE %s SET %s=%i, %s=%i, %s=%i '+
				'WHERE %s=%i AND %s=%s'
			, [
				TNAME.roles_affecting_geofences
				
				COL.visible, 1
				COL.score_modifier, data.scoreModifier
				COL.triggers, 1
				
				COL.role_id, data.roleId
				COL.visible, 0 #bad
				
			]
			# console.log sql
			
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'end', (info)->
					if info.affectedRows > 0
						def.resolve()
					else
						def.reject 'No rows affected'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
			
		# preforms the actions needed to save a geofence
		@saveGeofence: (data)->
			def = app.Q.defer()
			
			app.models.Map.createNewGeofence
				gameId: data.gameId
				missionId: data.missionId
				description: data.description
				longitude: data.longitude
				latitude: data.latitude
				color: data.color
			.then ()->
				
				app.models.Map.updateRolesGeofences
					roleId: app.hvz.roles.HUMAN.id
					scoreModifier: data.human
				.then ()->
					
					app.models.Map.updateRolesGeofences
						roleId: app.hvz.roles.ZOMBIE.id
						scoreModifier: data.zombie
					.then ()->
						
						app.models.Map.updateRolesGeofences
							roleId: app.hvz.roles.OZ.id
							scoreModifier: data.oz
						.then ()->
							
							def.resolve()
							
						, (err)->
							def.reject err
					, (err)->
						def.reject err
				, (err)->
					def.reject err
			, (err)->
				def.reject err
			return def.promise
				
		
		# gets all points
		@getAllGeofences: ()->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT %s,%s,%s FROM %s'
			, [
				COL.user_id
				COL.longitude
				COL.latitude
				
				TNAME
				COL.user_id
			]
			# console.log sql
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						userId: row.user_id
						longitude: row.longitude
						latitude: row.latitude
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
		
		
		