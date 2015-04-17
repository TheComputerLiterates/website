###
	API for Android

###

# This will be used to do the sha3 encyption as done on the website
# Use: SHA3.update(req.body.password).digest('hex')
SHA3 = require('sha3').SHA3Hash(512)

module.exports = (app) ->
	class app.APIController		

		# Test
		@test = (req, res)->
			if req.body.data? &&
			req.body.data == 'test'
				res.send
					success: true
					body:
						returnData: "Some string"
						rawr: 1
						arr: [
							3523
							72
							'Rawr'
						]
						obj:
							name: "Yay"
							obj:
								chicken: "moo"
			else
				res.send
					success: true
					body:
						error: "Invalid input. Must send a 'data' string with contents 'test'. You sent '"+ JSON.stringify(req.body) + "'"
						code: 42

		# POST: Login (req.body.email and req.body.password)
		@login = (req, res) ->
			if req.body.email? &&
			req.body.password?
				loginData = 
					email: req.body.email
					password: SHA3.update(req.body.password).digest('hex')

			p = app.models.User.checkLogin loginData
			p.then (userData) ->
				res.send
					success: true
					body:
						'message': 'User Login success: ' + userData.email

			, (err) ->
					res.send
						success: false
						body:
							'error': 'Invalid Login',
							'code': app.errors.INVALID_LOGIN


		# POST: Get the information of the profile by ID (req.body.id)
		@profileInfo = (req, res) ->
			p = app.models.User.getProfileByID req.body.id
			p.then (userData) ->
				res.send
					success: true
					body:
						'message': 'Got user information: ' + userData.email
					data: userData

			, (err) ->
					res.send
						success: false
						body:
							'error': 'User ID not found',
							'code': app.errors.USER_ID_NOT_FOUND
		