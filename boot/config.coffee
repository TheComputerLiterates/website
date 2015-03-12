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
emailTemplate = require '../lib/emailTemplate'

#JS utility libraries
util = require 'util'
vsprintf = require('sprintf-js').vsprintf

# Configuration
module.exports = (app) ->
	# Load random utility libraries
	app.util = util
	app.vsprintf = vsprintf
	
	# Load helper functions
	app.locals.helpers = require __dirname + '/../app/helpers'

	# Autoload controllers
	autoload 'app/controllers', app
		
	
	# Load .env
	dotenv.load()
	
	# Configure app settings
	env = process.env.NODE_ENV || 'development'
	app.set 'port', process.env.PORT || 5001
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
		secret: process.env.SECRET + ' '
		cookie:
			maxAge: 172800000		#2 days
		saveUninitialized: false
		resave: false
	app.use (req,res,next) ->
		res.locals.session = req.session;
		next();

	# Create Mandrill object TODO: setup mandrill account
	app.mandrill = new Mandrill.Mandrill process.env.MANDRILL_API_KEY  
	# Load email template function
	emailTemplate app
	
	#setup database, including a global persistent connection
	app.db = 
		Client: Mariasql
		setup:
			host: process.env.DATABASE_HOSTNAME
			user: process.env.DATABASE_USERNAME
			password: process.env.DATABASE_PASSWORD
			db: process.env.DATABASE_NAME
	app.db.newCon = ()->
			con = new app.db.Client()
			con.connect app.db.setup
			con.on 'connect', ()->
				this.tId = this.threadId #so it isnt deleted
				console.log '> DB: New connection established with threadId ' + this.threadId
			.on 'error', (err)->
				console.log '> DB: Error on threadId ' + this.threadId + '= ' + err
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
	console.log ("> MANDRILL_KEY=" + process.env.MANDRILL_API_KEY)
	console.log ("> SECRET=" + process.env.SECRET)
	console.log '-------------------------------'
		
	# EXAMPLE EMAIL:
	# app.emailTemplate 'accountCreated',
	# 	to_email: 'jrdbnntt@gmail.com'
	# 	from_email: 'account@hvzatfsu.com'
	# 	from_name: 'HvZ at FSU'
	# 	subject: 'Account Created!'
	# 	locals:
	# 		firstName: "Jared"
	# 		lastName: "Bennett"
		
