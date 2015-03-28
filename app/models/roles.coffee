###
	Roles model
	
	This is for edititing the many-many relationation tables, rather than the
	roles table. 
	
	Use app.hvz.roles to get the values of 'roles' instead of querying it.
###

#For all TREL
COL = 
	role_id: 'role_id'					#INT
	mission_id: 'mission_id'			#INT
	geopoint_id: 'geopoint_id'			#INT
	geofence_id: 'geofence_id'			#INT
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.roles
	#Related tables, Foreign-This
	TREL =
		roles_seeing_geopoints: 		app.models.C.TNAME.roles_seeing_geopoints
		roles_affecting_geofences: 	app.models.C.TNAME.roles_affecting_geofences
		roles_in_missions: 				app.models.C.TNAME.roles_in_missions

	
	class app.models.Roles
		constructor: ()->	
		
		# Creates new roles_in_missions
		@createNewRM: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s) VALUES '
			, [
				TREL.roles_in_missions
				
				COL.role_id
				COL.mission_id
			]
			
			# Account for mutliple roleIds
			for roleId in data.roleIds
				sql += '(' + roleId + ',' + data.missionId + '),'
			#remove last comma
			sql = sql.substr 0, (sql.length - 1)
			
			#Basic sql call syntax here
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
		
		# gets all roles_in_missions for a given mission
		@getAllRM: (missionId)->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT %s FROM %s WHERE %s = %i'
			, [
				COL.role_id
				TREL.roles_in_missions
				COL.mission_id
				missionId
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						roleId: row.role_id
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
		