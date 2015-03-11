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

			# EXAMPLE CREATING NEW USER
			userData = 
				email: 'jrdbnntt@gmail.com'
				password: 'pass'
				first_name: 'Jared'
				last_name: 'Bennett'
				email_subscribed: false
			
			p = app.models.User.checkEmailUsed userData.email
			p.then (used)->
				if used
					console.log 'CANNOT CREATE USER BECAUSE EMAIL IN USE'
				else
					app.models.User.createNew userData
			
			
			res.render 'public/signup',
				title: 'Sign Up' 
		
		# POST
		@signup_submit = (req,res) ->
			#todo