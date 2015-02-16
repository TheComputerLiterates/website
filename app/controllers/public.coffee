module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'public/index',
				title: 'Home' # TODO: replace 'Game' with Zombie/Human
		
		@login = (req, res) ->
			res.render 'public/login',
				title: 'Login' 
				
		
		@info = (req, res) ->
			res.render 'public/info',
				title: 'Info' 
		
		# SIGNUP ###############################################################
		#page
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
		
		#post
		@signup_submit = (req,res) ->
			
			
			