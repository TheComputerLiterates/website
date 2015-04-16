###
	ClarificationRequest (CR) model
		- create new CR
		- display CR
		- add comment to CR
		- delete CR
		- open/close CR

###

COL = 
	id: 'id'									#INT, PK
	open_user_id: 'open_user_id'		#INT, FK
	close_user_id: 'close_user_id'	#INT, FK
	game_id: 'game_id'					#INT, FK
	mission_id: 'mission_id'			#INT, FK
	subject: 'subject'					#VARCHAR(45)
	description: 'description'			#TEXT(2000)
	personal: 'personal'					#BOOLEAN
	closed: 'closed'						#BOOLEAN
	created_at: 'created_at'			#DATETIME
	updated_at: 'updated_at'			#DATETIME
	replies: 'replies'					#INT
	
	# Comment cols
	#id 																	#INT, PK
	clarification_request_id: 'clarification_request_id'	#INT, FK
	user_id: 'user_id'												#INT, FK
	comment: 'comment'												#TEXT(2000)
	position: 'position'												#INT
	#created_at															#DATETIME
	
	#Game/mission
	title: 'title'
	
	#User
	first_name: 'first_name'
	last_name: 'last_name'
	
module.exports = (app) ->
	TNAME = app.models.C.TNAME.clarification_request
	#Related tables, Foreign-This
	TREL =
		user: app.models.C.TNAME.user
		game: app.models.C.TNAME.game
		mission: app.models.C.TNAME.mission
		clarification_request_comment: app.models.C.TNAME.clarification_request_comment
	
	
	class app.models.ClarificationRequest
		constructor: ()->	
		
		@createNew: (data) ->
			console.log app.util.inspect data
			
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s ' +
				'(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) VALUES (%i,%s,' +
					(if data.gameId? then data.gameId else 'NULL') + ',' +
					(if data.missionId? then data.missionId else 'NULL') + ',' +
					'"%s","%s",%i,%i,%s,%s,%i)'
			, [
				TNAME
				
				COL.open_user_id
				COL.close_user_id
				COL.game_id
				COL.mission_id
				COL.subject
				COL.description
				COL.personal
				COL.closed
				COL.created_at
				COL.updated_at
				COL.replies
				
				data.openUserId
				'NULL'
				#
				#
				data.subject
				data.description
				if data.personal then 1 else 0
				0 #false
				'NOW()'
				'NOW()'
				0 #false
				
			]
			console.log sql
			
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
		
		# Returns all CRs visible by userId with roleId
		@getAllByUserIdRoleId: (userId, roleId)->
			deferred = app.Q.defer()
			
			complete = (sql)->
				result = []
				con = app.db.newCon()
				con.query sql 
				.on 'result', (res)->
					res.on 'row', (row)->
						result.push 
							crId: parseInt row.id
							openUserId: parseInt row.open_user_id
							closeUserId: parseInt row.close_user_id
							closed: row.closed == '1'
							subject: row.subject
							gameTitle: row.gameTitle
							replies: row.replies
							missionTitle: row.missionTitle
							userName: row.first_name + ' ' + row.last_name
							createdAt: app.locals.helpers.momentMariadbRelative app.moment, row.created_at
							updatedAt: app.locals.helpers.momentMariadbRelative app.moment, row.updated_at
					res.on 'end', (info)->
						console.log 'Got ' + info.numRows + ' rows from ' + TNAME
						deferred.resolve result
				.on 'error', (err)->
					console.log "> DB: Error on old threadId " + this.tId + " = " + err
					deferred.reject err
				con.end()
				
			# Generate correct sql
			if roleId < app.hvz.roles.MODERATOR.id
				#Have to check userId, gameId, then missionId
				# app.models.Game.getCurrentGame()
				# .then (currGame)->
				# 	def.resolve app.vsprintf 'SELECT cr.* FROM %s AS cr ' +
				# 		'LEFT JOIN %s AS g ON cr.%s = g.%s' +
				# 		'LEFT JOIN %s AS m ON cr.%s = m.%s' +
				# 		'WHERE '
				# 	, [
				# 		TNAME
				# 		TREL.user
				# 		TREL.mission
						
				# 		COL.game_id
				# 		COL.id
				# 		COL.mission_id
				# 		COL.id
						
				# 	]
				# , (err)->
				# 	def.reject err
			else
				sql = app.vsprintf 'SELECT cr.*, g.%s AS %s, m.%s AS %s, ' +
					'u.%s, u.%s ' +
					'FROM %s AS cr ' +
					'INNER JOIN %s AS u ON cr.%s = u.%s ' +
					'LEFT JOIN %s AS g ON cr.%s = g.%s ' +
					'LEFT JOIN %s AS m ON cr.%s = m.%s ' +
					'ORDER BY cr.%s DESC'
				, [
					COL.title, 'gameTitle'
					COL.title, 'missionTitle'
					COL.first_name
					COL.last_name
					
					TNAME
					TREL.user, COL.open_user_id, COL.id
					TREL.game, COL.game_id, COL.id
					TREL.mission, COL.mission_id, COL.id
					
					COL.game_id, COL.id
					COL.mission_id, COL.id
					
					COL.created_at
					
				]
				# console.log sql
				complete sql
			
				
			return deferred.promise
		
		
		# Returns all comments for a given CR.id
		@getAllComments: (crId)->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT c.*, u.%s, u.%s ' +
				'FROM %s AS c INNER JOIN %s AS u ON c.%s = u.%s' +
				'WHERE %s = %i ' + 
				'ORDER BY c.%s DESC'
			, [
				COL.first_name
				COL.last_name
				
				TNAME, TREL.user
				COL.user_id, COL.id
				
				COL.clarification_request_id, crId
				
				COL.created_at
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						commentId: parseInt row.id
						crId: parseInt row.clarification_request_id
						text: row.comment
						userName: row.first_name + ' ' + row.last_name
						createdAt: app.locals.helpers.momentMariadbRelative app.moment, row.created_at
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
