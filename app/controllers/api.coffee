###
	API for Android

###

# This will be used to do the sha3 encyption as done on the website
# Use: SHA3.update(req.body.password).digest('hex')
#SHA3 = require('sha3').SHA3Hash(512)

module.exports = (app) ->
	class app.APIController		

		############################################################################
		# PUBLIC: /

		# POST: /login
		# Requires: email, password
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
						error: 'Invalid Parameters',
						code: app.errors.INVALID_PARAMETERS
						expected: 'email (string), password (string)'
						received: req.body



		############################################################################
		# USER: /user

		# POST: /user/profile
		# Requires: userId
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
						error: 'Invalid Parameters',
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int)'
						received: req.body


		############################################################################
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
						error: 'Invalid Parameters',
						code: app.errors.INVALID_PARAMETERS
						expected: 'userId (int), HVZID (int)'
						received: req.body

		# POST: /game
		# Requires: roleId
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
						error: 'Invalid HVZID',
						code: app.errors.INVALID_HVZID
						
						
		#######################################################################
		# GPS
		
		# Saving user gps points
		@map_userGeopointCreate = (req,res)->
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
						error: 'Invalid Parameters',
						code: app.errors.INVALID_PARAMETERS
						expected: 'roleId (int)'
						received: req.body
		
		# Recieve all points
		@map_userGeopointGetRefreshed = (req,res)->
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
