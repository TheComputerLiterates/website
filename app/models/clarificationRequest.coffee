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
				1 #true
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
		
		# gets all games
		@getAll: ()->
			deferred = app.Q.defer()
			sql = app.vsprintf 'SELECT %s,%s,%s,%s,%s,%s FROM %s'
			, [
				COL.id
				COL.start_date
				COL.end_date
				COL.title
				COL.description
				COL.visible
				
				TNAME
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						gameId: row.id
						startDate: app.moment(row.start_date)
						endDate: app.moment(row.end_date)
						title: row.title
						description: row.description
						visible: (parseInt row.visible) == 0
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					deferred.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				deferred.reject err
			con.end()
			
			return deferred.promise
		
