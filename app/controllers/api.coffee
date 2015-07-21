###
	API for Android

###

# This will be used to do the sha3 encyption as done on the website
# Use: SHA3.update(req.body.password).digest('hex')
#SHA3 = require('sha3').SHA3Hash(512)

module.exports = (app) ->
	class app.APIController		

		#######################################################################
		# PUBLIC: /

		# POST: /login
		# Requires: email (string), password (string)
		# Login
		@login = (req, res) ->
			# console.log app.util.inspect req.body
			if req.body.email? &&
			req.body.password?
				loginData = 
					email: req.body.email
					#password: SHA3.update(req.body.password).digest('hex')
					password: req.body.password

				p = app.models.User.checkLogin loginData
				p.then (userData) ->
					# console.log "Login Success!"
					# console.log app.util.inspect userData
					res.send
						success: true
						body: 
							firstName: userData.firstName
							lastName: userData.lastName
							email: userData.email
							HVZID: userData.HVZID
							roleId: userData.roleId
							roleName: app.hvz.getRoleById userData.roleId 
							userId : userData.userId

				, (err) ->
					# console.log "Login FAIL!"
					res.send
						success: false
						body:
							error: 'Invalid Login',
							code: app.errors.INVALID_LOGIN

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'email (string), password (string)'
						received: req.body



		#######################################################################
		# USER: /user

		# POST: /user/profile
		# Requires: userId (int)
		# Get the information of the profile by ID
		@user_profile = (req, res) ->
			if req.body.userId?
				p = app.models.User.getProfileByUserId parseInt(req.body.userId)
				p.then (userData) ->
					res.send
						success: true
						body:
							firstName: userData.firstName
							lastName: userData.lastName
							email: userData.email
							HVZID: userData.HVZID
							roleId: userData.roleId
							roleName: app.hvz.getRoleById userData.roleId 
							userId : userData.userId

				, (err) ->
						res.send
							success: false
							body:
								error: 'User ID not found',
								code: app.errors.USER_ID_NOT_FOUND

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int)'
						received: req.body



		#######################################################################
		# CLARIFICATION REQUESTS: /user/cRequest...

		# POST: /user/cRequestCreate
		# Requires: roleId (int)
		# Get the availavle options for creating the Clarification Request
		@user_cRequestCreate = (req, res) ->
			if req.body.roleId?
				if req.body.roleId >= app.hvz.roles.USER.id
					# Construct them
					app.models.Game.getAllTitles()
					.then (games)->
						app.models.Mission.getTitlesByRole parseInt(req.body.roleId)
						.then (missions)->						
							# Add role name befor each title
							for mission in missions
								mission.title = app.hvz.getRoleById(mission.roleId) +
									" - " + mission.title
							res.send
								success: true
								body:
									gameData: games
									missionData: missions
						, (err)->
							success: true
							body:
								gameData: games
								missionData: {}
					, (err)->
						success: true
						body:
							gameData: {}
							missionData: {}
				else
					success: true
					body:
						gameData: {}
						missionData: {}

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'roleId (int)'
						received: req.body

		# POST: /user/cRequestCreate_submit
		# Requires: userId (int), subject (string), description (string), personal (boolean)
		# Submit the clarification request
		@user_cRequestCreate_submit = (req, res)->
			if req.body.userId? &&
			req.body.subject? &&
			req.body.description? &&
			req.body.personal?
				
				app.models.ClarificationRequest.createNew 
					subject: req.body.subject
					description: req.body.description
					personal: req.body.personal == 'true'
					gameId: req.body.gameId				#can be undefined
					missionId: req.body.missionId		#can be undefined
					openUserId: parseInt req.body.userId
				.then ()->
					res.send
						success: true
						body: {}	
				, (err)->
					res.send
						success: false
						body:
							error: err
							code: app.errors.db.EXECUTION

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), subject (string), description (string), personal (true/false)'
						received: req.body

		# POST: /user/cRequestView
		# Requires: userId (int), roleId (int)
		# View the clarification requests
		@user_cRequestView = (req, res)->
			if req.body.userId? &&
			req.body.roleId?
				app.models.ClarificationRequest.getAllByUserIdRoleId req.body.userId, 
				req.body.roleId
				.then (cRequests)->
					res.send
						success: true
						body: 
							cRequests: cRequests
				, (err)->
					res.send
						success: false
						body:
							error: 'Clarification Requests not found',
							code: app.errors.CR_NOT_FOUND

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), roleId (int)'
						received: req.body

		# POST: /user/cRequestView_commentCreate
		# Requires: userId (int), crId (int), comment (string)
		# Create a comment in the Clarification Request
		@user_cRequestView_commentCreate = (req, res)->
			if req.body.crId? &&
			req.body.comment? &&
			req.body.userId

				app.models.ClarificationRequest.addComment
					crId: req.body.crId
					comment: req.body.comment
					userId: req.body.userId
				.then ()->
					res.send
						success: true
						body: {}	
				, (err)->
					res.send
						success: false
						body:
							error: err
							code: app.errors.db.EXECUTION
			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), crId (int), comment (string)'
						received: req.body


		# POST: /user/cRequestView_commentGet
		# Requires: crId (int)
		# Get comments of Clarification Request
		@user_cRequestView_commentGet = (req, res)->
			if req.body.crId?
				app.models.ClarificationRequest.getAllComments req.body.crId
				.then (comments)->
					res.send
						success: true
						body: 
							comments: comments
				, (err)->
					res.send
						success: false
						body:
							error: err
							code: app.errors.db.EXECUTION
			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'crId (int)'
						received: req.body


		#######################################################################
		# GAME: /game

		# POST: /game/kill
		# Requires: userId (Zombie), HVZID (Human)
		# Report a Kill
		@game_kill_submit = (req, res) ->
			if req.body.userId? &&
			req.body.HVZID?
				p = app.models.PlayerKill.createNew parseInt(req.body.userId), 
					parseInt(req.body.HVZID)
				p.then ()->
					res.send
						success: true
						body: {}
							
				, (err)->
					res.send
						success: false
						body:
							error: 'Invalid HVZID',
							code: app.errors.INVALID_HVZID

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), HVZID (int)'
						received: req.body

		# POST: /game
		# Requires: roleId (int)
		# Get Current game information
		@game = (req, res) ->
			if req.body.roleId?
				gDateFormat = 'MMMM Do'
				mDateFormat = 'ddd h:mma'

				# Get current game information
				p = app.models.Game.getCurrentGame()
				p.then (gameData)->
					if gameData.gameId?
						# Format game dates
						gameData.startDate = gameData.startDate.format gDateFormat
						gameData.endDate = gameData.endDate.format gDateFormat

						# Grab all missions
						p2 = app.models.Mission.getMissionsByGameRole gameData.gameId, parseInt(req.body.roleId)
						p2.then (missionData)->
							# Format mission data
							for m in missionData
								m.startDate = m.startDate.format mDateFormat
								m.endDate = m.endDate.format mDateFormat
								m.roleName = app.hvz.getRoleById(m.roleId).toUpperCase()

							res.send
								success: true
								body:
									gameData: gameData
									missionData: missionData

						, (err)->
							res.send
								success: false
								body:
									error: 'Problem loading missions.'
									code: app.errors.GET_MISSION_ERROR

					else 
						res.send
							success: false
							body:
								error: 'No game found'
								code: app.errors.GAME_NOT_FOUND

				, (err)->
					res.send
						success: false
						body:
							error: 'Problem loading current game.'
							code: app.errors.GET_GAME_ERROR

			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_HVZID
						
						
		#######################################################################
		# MAP: /map
		
		# POST: /map/userGeopointCreate
		# Requires: userId (int), longitude (double), latitude (double)
		# Saving user gps points
		@map_userGeopointCreate = (req, res) ->
			if req.body.userId? &&
			req.body.longitude? &&
			req.body.latitude?
				app.models.UserGeopoint.createNew
					userId: req.body.userId
					longitude: parseFloat req.body.longitude
					latitude: parseFloat req.body.latitude
				.then ()->
					res.send
						success: true
						body: {}
				, (err)->
					res.send
						success: false
						body: 
							error: err
							code: app.errors.db.EXECUTION
			else
				res.send
					success: false
					body:
						error: app.errors.INVALID_PARAMETERS_TEXT,
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), longitude (double), latitude (double)'
						received: req.body
		
		# POST: /map/userGeopointGetRefreshed
		# Requires: NULL
		# Recieve all points
		@map_userGeopointGetRefreshed = (req, res) ->
			app.models.UserGeopoint.getAllRefreshed()
			.then (pts)->
				res.send
					success: true
					body:
						pts: pts
			, (err)->
				res.send
					success: false
					body:
						error: err
						code: app.errors.db.EXECUTION
		
		@map_create_geofence = (req,res) ->
			console.log 'BODY=' + app.util.inspect req.body
			if req.body.gameId? &&
			req.body.missionId? &&
			req.body.human? &&
			req.body.zombie? &&
			req.body.oz? &&
			req.body.color? &&
			req.body.latitude? &&
			req.body.longitude? &&
			req.body.radius? &&
			req.body.description?
				app.models.Map.saveGeofence
					gameId: parseInt req.body.gameId
					missionId: parseInt req.body.missionId
					human: parseInt req.body.human
					oz: parseInt req.body.oz
					zombie: parseInt req.body.zombie
					color: parseInt req.body.color.replace(/#/g,''), 16
					latitude: parseFloat req.body.latitude
					longitude: parseFloat req.body.longitude
					radius: parseInt req.body.radius
					description: req.body.description
				.then ()->
					# console.log 'yay'
					res.send
						success: true
						body: {}
				, (err)->
					res.send
						success: false
						body:
							error: err
							code: app.errors.db.EXECUTION
			else
				res.send
					success: false
					body:
						error: 'Invalid Parameters'
						code: app.errors.INVALID_PARAMETERS
			
		@map_create_geopoint = (req,res) ->
		
		
		@map_get_geofence_all = (req,res)->
			app.models.Map.geofence.getFull.all()
			.then (geofences)->
				# console.log 'yay'
				res.send
					success: true
					body:
						geofences: geofences
			, (err)->
				res.send
					success: false
					body:
						error: err
						code: app.errors.db.EXECUTION
		
		@map_get_geopoint_all = (req,res)->
			app.models.Map.geopoint.getFull.all()
			.then (geopoints)->
				res.send
					success: true
					body:
						geopoints: geopoints
			, (err)->
				res.send
					success: false
					body:
						error: err
						code: app.errors.db.EXECUTION
