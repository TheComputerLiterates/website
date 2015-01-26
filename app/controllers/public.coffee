module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'public/index',
				title: 'Home' # TODO: replace 'Game' with Zombie/Human
		
		@login = (req, res) ->
			res.render 'public/login',
				title: 'Login' 
				
		@signup = (req, res) ->
			res.render 'public/signup',
				title: 'Signup' 
		
		@info = (req, res) ->
			res.render 'public/info',
				title: 'Info' 