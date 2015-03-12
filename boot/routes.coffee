###

All routes go here

See README for a simplified list.

###
acl = require '../lib/acl'
bodyParser = require 'body-parser'

module.exports = (app) ->
	#Body parsers
	jsonParser = bodyParser.json()
	urlencodedParser = bodyParser.urlencoded {extended: false}
	
	# Enforce ACL
	app.use acl
	
	
	# PUBLIC PAGES ############################################################
	# Site Home
	app.get '/', app.PublicController.index
	app.get '/home', app.PublicController.index
	app.get '/index', app.PublicController.index
	
	# Login
	app.get '/login', app.PublicController.login
	app.post '/login', jsonParser, app.PublicController.login_submit

	# Signup
	app.get '/signup', app.PublicController.signup
	app.post '/signup', jsonParser, app.PublicController.signup_submit
	
	# Info
	app.get '/info', app.PublicController.info
	
	# USER PAGES ##############################################################
	# Profile
	app.get '/user/profile', app.UserController.profile
	
	# Forum
	app.get '/user/forum', app.UserController.forum
	
	# Stats
	app.get '/user/stats', app.UserController.stats
	

	# GAME (player) PAGES #####################################################
	# Game home
	app.get '/game', app.GameController.index
	
	# Missions
	app.get '/game/missions', app.GameController.missions
	
	# Map
	app.get '/game/map', app.GameController.map
	
	# Kill
	app.get '/game/kill', app.GameController.kill
	
	
	# MOD PAGES ###############################################################
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


	# DATA ####################################################################
	app.post '/data/currentgame', app.DataController.currentGame
	
	# API #####################################################################

	
	
	# Page not found (404) ####################################################
	# This should always be the LAST route specified
	app.get '*', (req, res) ->
		res.render 'public/404', title: 'Error 404'
