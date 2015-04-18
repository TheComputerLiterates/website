###
	Handles user_geopoint

###




COL = 
	id: 'id'									#INT
	user_id: 'user_id'					#INT
	longitude: 'longitude'				#DECIMAL
	latitude: 'latitude'					#DECIMAL
	timestamp: 'timestamp'				#DATETIME
	
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.user_geopoint
		
	#Related tables, Foreign-This
	TREL =
		user: 			app.models.C.TNAME.user
	
	class app.models.UserGeopoint
		constructor: ()->	
		
		# Creates a new game in the database.
		@createNew: (data) ->
			# console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s) VALUES (%i,%f,%f,%s)'
			, [
				TNAME
				
				COL.user_id
				COL.longitude
				COL.latitude
				COL.timestamp
				
				data.userId
				data.longitude
				data.latitude
				'NOW()'
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
		
		# Deletes all old points
		@wipeOld: ()->
			deferred = app.Q.defer()
			sql = app.vsprintf 'DELETE FROM %s WHERE %i < TIMESTAMPDIFF(SECOND,%s,NOW()) '
			, [
				TNAME
				10
				COL.timestamp
			]
			# console.log sql
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'end', (info)->
					console.log 'Deleted ' + info.affectedRows + ' rows from ' + TNAME
					deferred.resolve()
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
		
		# gets all points
		@getAll: ()->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT %s,%s,%s FROM %s'
			, [
				COL.user_id
				COL.longitude
				COL.latitude
				
				TNAME
				COL.user_id
			]
			console.log sql
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
		
		# Gets all points after wiping olds ones
		@getAllRefreshed: ()->
			def = app.Q.defer()
			
			# Wipe
			app.models.UserGeopoint.wipeOld()
			.then ()->
				# Get
				app.models.UserGeopoint.getAll()
				.then (res)->
					def.resolve res
				, (err)->
					def.reject err
			, (err)->
				def.reject err
				
			return def.promise
				