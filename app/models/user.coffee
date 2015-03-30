###
	User model, for accessing user stuff

###

#table constants
COL = 
	id: 'id'														#INT
	role_id:	'role_id'										#INT - FK
	android_instance_id: 'android_instance_id'		#INT - FK
	website_instance_id: 'website_instance_id'		#INT - FK
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
	TNAME = app.models.C.TNAME.user
	
	# Related tables, Foriegn-This (FK)
	TREL =
		role: 							app.models.C.TNAME.role							# 1<-* (role_id)
		forum_post: 					app.models.C.TNAME.forum_post					# *->1
		geopoint: 						app.models.C.TNAME.geopoint					# *->1
		clarification_request: 		app.models.C.TNAME.clarification_request	# *->1, *->1
		users_in_games: 				app.models.C.TNAME.users_in_games			# game<-*->1
		users_in_missions:			app.models.C.TNAME.users_in_missions		# mission<-*->1
		player_kill:					app.models.C.TNAME.player_kill				# *->1, *->1
		android_instance:				app.models.C.TNAME.android_instance 		# 1<-* (android_instance_id)
		website_instance:				app.models.C.TNAME.website_instance 		# 1<-* (website_instance_id)
	
	class app.models.User
		constructor: ()->		
		
		# Creates a new user in the database.
		@createNew: (data) ->
			#email MUST be checked for existence prior to call
			def = app.Q.defer()
			
			#Encrypt password
			app.bcrypt.genSalt 10, (err,salt)->
				app.bcrypt.hash data.password, salt, (err, hash)->
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
						hash
						data.first_name
						data.last_name
						if data.email_subscribed then 1 else 0
						app.models.C.RNAME.genUniqueHVZID + '()'
						'NOW()'
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
			
			return deferred.promise
		
		#checks if it is a valid login
		@checkLogin: (loginInfo) ->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT * FROM %s WHERE %s = "%s"'
			, [
				app.models.C.VNAME.user_credentials_with_role
				COL.email
				loginInfo.email
			]
			
			userData = {}
			passTemp = null
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					#user found
					passTemp = row.password
					userData =
						userId: row.user_id
						email: row.email
						roleId: row.role_id
						HVZID: row.HVZID
						firstName: row.first_name
						lastName: row.last_name

				res.on 'end', (info)->
					if info.numRows > 0
						# check password
						
						app.bcrypt.compare loginInfo.password, passTemp, (err, res)->
							if res #valid password
								# console.log '> DB: Valid login found for "'+userData.email+'"'
								def.resolve userData
							else
								console.log 'LOGIN: Invalid password for "'+userData.email+'"'
								def.reject 'Invalid login credentials'
							return
					else
						console.log 'LOGIN: Invalid email'
						def.reject 'Invalid login credentials'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject 'A problem occured checking login credentials'
				
			con.end()
			return def.promise
		
		# Changes the role of a user
		@setRole: (user_id, role_id)->
			deferred = app.Q.defer()
			sql = app.vsprintf 'UPDATE %s SET %s = "%s" WHERE %s = "%s" LIMIT 1'
			, [
				TNAME
				
				COL.role_id
				role_id
				
				COL.user_id
				user_id
			]
			
			con = app.db.newCon()
			con.query sql
			.on 'end', (info)->
				if info.numRows
					deferred.resolve()
				else
					deferred.reject 'Invalid user_id'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
			

		@getRoleCount: (role_id) ->
			count = null
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT COUNT(*) AS c FROM %s WHERE %s = %s'
			, [
				TNAME
				COL.role_id
				role_id
			]

			con = app.db.newCon()
			con.query sql

			.on 'result', (res)->
				res.on 'row', (row) ->
					count = row.c
				res.on 'end', (info)->
					deferred.resolve count
					console.log count
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err

			con.end()

			return deferred.promise			