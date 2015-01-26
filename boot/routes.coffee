###

All routes go here

See README for a simplified list.

###

module.exports = (app) ->
	# PUBLIC PAGES ###############################################
	
	# Site Home
	app.get '/', app.PublicController.index
	app.get '/home', app.PublicController.index
	app.get '/index', app.PublicController.index
	
	# Login
	app.get '/login', app.PublicController.login
	
	# Signup
	app.get '/signup', app.PublicController.signup
	
	# Info
	app.get '/info', app.PublicController.info
	
	# USER PAGES ################################################# 
	
	# Profile
	app.get '/user/profile', app.UserController.profile
	
	# Forum
	app.get '/user/forum', app.UserController.forum
	
	# Stats
	app.get '/user/stats', app.UserController.stats
	

	# GAME (player) PAGES ###############################################
	
	# Game home
	app.get '/game', app.GameController.index
	
	# Missions
	app.get '/game/missions', app.GameController.missions
	
	# Map
	app.get '/game/map', app.GameController.map
	
	# Kill
	app.get '/game/kill', app.GameController.kill
	
	
	# MOD PAGES ##################################################
	
	# Mod home
	app.get '/mod', app.ModController.index
	
	# User management
	app.get '/mod/users', app.ModController.users
	
	# Game management
	app.get '/mod/game', app.ModController.game
	
	# Development
	app.get '/mod/dev', app.ModController.dev
	
	# Information edit/docs
	app.get '/mod/info', app.ModController.info

	
	
	# Page not found (404) #######################################
	# This should always be the LAST route specified
	app.get '*', (req, res) ->
		res.render '404', title: 'Error 404'
