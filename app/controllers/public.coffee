module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'public/index',
				title: 'Home' # TODO: replace 'Game' with Zombie/Human

		@info = (req, res) ->
			res.render 'public/info',
				title: 'Info' 

		# LOGIN ################################################################
		# Page (GET)
		@login = (req, res) ->
			res.render 'public/login',
				title: 'Login' 

		# POST
		@login_submit = (req, res) ->
			res.send "Data: " + req.body.emailUsername + " " + req.body.password		
		

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
			res.render 'public/test', { firstName: req.body.firstName }