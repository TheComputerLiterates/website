###
	User model, for accessing user stuff

###

#table constants
TNAME = 'user'
COL = 
	id: 'id'														#INT
	role_id:	'role_id'										#INT
	android_instance_id: 'android_instance_id'		#INT
	website_instance_id: 'website_instance_id'		#INT
	HVZID: 'HVZID'												#INT '123456789'
	email: 'email'												#VARCHAR(70)
	password: 'password'										#VARCHAR(128)
	first_name: 'first_name'								#VARCHAR(35)
	last_name: 'last_name'									#VARCHAR(35)
	created_at: 'created_at'								#DATETIME
	kills: 'kills'												#INT(2)
	active: 'active'											#BOOL
	email_subscribed: 'email_subscribed'				#BOOL
	
	
module.exports = (app) ->
	class app.models.User
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
		
		# Creates a new user in the database. Returns success/fail
		@createNew: (data) ->
			#email MUST be checked for existence prior to call
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s) VALUES ("%s","%s","%s","%s",%i,%s,%s)'
			, [
				TNAME
				
				COL.email
				COL.password
				COL.first_name
				COL.last_name
				COL.email_subscribed
				COL.HVZID
				COL.created_at
				
				data.email
				data.password
				data.first_name
				data.last_name
				if data.email_subscribed then 1 else 0
				'genUniqueHVZID()'
				'NOW()'
			]
			
			#Basic sql call syntax here
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				return false
			.on 'end', ()->
				return true
			con.end()
		
		# Checks if this email belongs to a user. Returns true/false in promise
		@checkEmailUsed: (email) ->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT COUNT(*) AS c FROM %s WHERE %s = "%s"'
			, [
				TNAME
				COL.email
				email
			]
			
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					if row.c == '0'
						deferred.resolve false
					else
						deferred.resolve true
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject()
				
			con.end()
			
			deferred.promise
		