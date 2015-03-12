module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'public/index',
				title: 'Home' # TODO: replace 'Game' with Zombie/Human

		@info = (req, res) ->
			res.render 'public/info',
				title: 'Info' 

		# LOGIN ################################################################
		#page
		@login = (req, res) ->
			
			#login verifiction example
			loginData = 
				email: 'jrdbnntt@gmail.com'
				password: 'pass'
			p = app.models.User.checkLogin loginData
			p.then (success, userData)->
				if success
					console.log 'LOGIN VALID!'
					console.log 'USERDATA: '+ JSON.stringify userData
				else
					console.log 'LOGIN INVALID!'
			.then (error)->
				#problem executing sql
			
			
			res.render 'public/login',
				title: 'Login' 
		
		#post
		@login_submit = (req, res) ->
			#TODO
		

		# SIGNUP ###############################################################
		# Page (GET)
		@signup = (req, res) ->
			res.render 'public/signup',
				title: 'Sign Up'
		
		# POST
		@signup_submit = (req,res) ->
			#TODO form validation
			console.log 'SIGNUP: ' + JSON.stringify req.body, undefined, 2
			if req.body.firstName? &&
			req.body.lastName? &&
			req.body.email? &&
			req.body.emailSubscribed? &&
			req.body.password?
				
				#set up db storage
				userData = 
					email: req.body.email
					password: req.body.password
					first_name: req.body.firstName
					last_name: req.body.lastName
					email_subscribed: req.body.emailSubscribed
				
				
				p = app.models.User.checkEmailUsed userData.email
				p.then (inUse)->
					if !inUse
						p = app.models.User.createNew userData
						p.then ()->
							console.log 'Account Created with email "' + userData.email + '"'
							res.send
								success: true
								msg: 'Account Created'
								
						, (err)->
							res.send
								success: false
								msg: 'Account creation error: ' + err
					else
						console.log 'CANNOT CREATE USER BECAUSE EMAIL IN USE'
						res.send
							success: false
							msg: 'Email already in use'
												
			else
				res.send
					success: false
					msg: 'Invalid parameters'
			