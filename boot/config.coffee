###
# Loads module dependencies and configures app.
###

# Module dependencies

validator = require 'express-validator'
Mandrill = require 'mandrill-api/mandrill'
autoload = require '../lib/autoload'
session = require 'express-session'
dotenv = require 'dotenv'
Q = require 'q'
Mariasql = require 'mariasql'
moment = require 'moment'

#JS utility libraries
util = require 'util'
vsprintf = require('sprintf-js').vsprintf
bcrypt = require 'bcrypt'

#App specific
hvz = require '../lib/hvz'
global = require '../lib/global'

# Configuration
module.exports = (app) ->
	# Load random utility libraries
	app.util = util
	app.vsprintf = vsprintf
	app.bcrypt = bcrypt
	app.moment = moment
	
	# Load helper functions
	app.locals.helpers = require __dirname + '/../app/helpers'

	# Autoload controllers
	autoload 'app/controllers', app
		
	
	# Load .env
	dotenv.load()
	app.env = process.env
	
	# Configure app settings
	env = app.env.NODE_ENV || 'development'
	app.set 'port', app.env.PORT || 5001
	app.set 'views', __dirname + '/../app/views'
	app.set 'view engine', 'jade'
	app.use require('express').static __dirname + '/../public'
	app.use validator()

	# Development settings
	if (env == 'development')
		app.locals.pretty = true
		
	#Session settings
	app.use session 
		name: 'connect.sid'
		secret: app.env.SECRET + ' '
		cookie:
			maxAge: 172800000		#2 days
		saveUninitialized: false
		resave: false
	app.use (req,res,next) ->
		res.locals.session = req.session;
		next();

	# Create Mandrill object TODO: setup mandrill account
	app.mandrill = new Mandrill.Mandrill app.env.MANDRILL_API_KEY
	# Load email template function
	require('../lib/emailTemplate')?(app)
	
	
	#setup database, including a global persistent connection
	app.db = 
		Client: Mariasql
		setup:
			host: app.env.DATABASE_HOSTNAME
			port: app.env.DATABASE_PORT
			user: app.env.DATABASE_USERNAME
			password: app.env.DATABASE_PASSWORD
			db: app.env.DATABASE_NAME
	app.db.newCon = ()->
			con = new app.db.Client()
			con.connect app.db.setup
			con.on 'connect', ()->
				this.tId = this.threadId #so it isnt deleted
				console.log '> DB: New connection established with threadId ' + this.tId
			.on 'error', (err)->
				console.log '> DB: Error on threadId ' + this.tId + '= ' + err
			.on 'close', (hadError)->
				if hadError
					console.log '> DB: Connection closed with old threadId ' + this.tId + ' WITH ERROR!'
				else
					console.log '> DB: Connection closed with old threadId ' + this.tId + ' without error'
			return con
	# app.db.con = app.db.newCon(); #global, persistent connection, others can be made later
	# app.db.con.on 'connect', ()->
	# 	console.log '> DB: Global connection started'
	# .on 'error', (err)->
	# 	console.log '> DB: Global connection error: ' + err
	# .on 'close', (hadError)->
	# 	console.log '> DB: Global connection interrupted, reconnecting..'
	# 	app.db.con.connect app.db.setup
	
	#setup models (must setup db first)
	app.Q = Q
	app.models = {}
	autoload 'app/models', app
	
	
	#debug crap
	console.log ("> MANDRILL_KEY=" + app.env.MANDRILL_API_KEY)
	console.log ("> SECRET=" + app.env.SECRET)
	console.log '-------------------------------'
	
	
	
	# HvZ Config Constants
	app.hvz = hvz
	app.locals.hvz = hvz

	# Global Variables (Shown throughout the site)
	app.global = global app
	app.locals.global = app.global

	console.log app.locals.global
				
