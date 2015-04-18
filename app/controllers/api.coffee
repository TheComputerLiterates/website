###
	API for Android

###

# This will be used to do the sha3 encyption as done on the website
# Use: SHA3.update(req.body.password).digest('hex')
#SHA3 = require('sha3').SHA3Hash(512)

module.exports = (app) ->
	class app.APIController		

		# POST: Login (req.body.email and req.body.password)
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
				console.log app.util.inspect userData
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


		# POST: Get the information of the profile by ID (req.body.id)
		@profile = (req, res) ->
			p = app.models.User.getProfileByID req.body.id
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

		# POST: Report a Kill
		@kill_submit = (req, res)->
			p = app.models.PlayerKill.createNew req.body.userId, 
				req.body.HVZID
			p.then ()->
				res.send
					success: true
						
			, (err)->
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
						error: 'Invalid parameters. Expected {userid,longitude,latitude}. Got ' + JSON.stringify req.body
						code: 142412 #update this
		
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