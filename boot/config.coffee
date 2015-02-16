###
# Loads module dependencies and configures app.
###

# Module dependencies
bodyParser = require 'body-parser'
validator = require 'express-validator'
Mandrill = require 'mandrill-api/mandrill'
autoload = require '../lib/autoload'
session = require 'express-session'
cookieParser = require 'cookie-parser'
dotenv = require 'dotenv'
acl = require '../lib/acl'
flash = require 'express-flash'
emailTemplates = require 'email-templates'
Q = require 'q'
Mariasql = require 'mariasql'

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
	app.use bodyParser.json()
	app.use bodyParser.urlencoded {extended: true} 

	# Development settings
	if (env == 'development')
		app.locals.pretty = true
		
	#Session settings
	app.use session 
		name: 'connect.sid'
		secret: process.env.SECRET + ' '
		cookie:
			maxAge: 864000		#10 days
		saveUninitialized: false
		resave: false
	app.use (req,res,next) ->
		res.locals.session = req.session;
		next();
	
	# Handle Flash messages
	app.use cookieParser(process.env.SECRET + ' ')
	app.use flash()
	
	# Create Mandrill object TODO: setup mandrill account
	app.mandrill = new Mandrill.Mandrill process.env.MANDRILL_API_KEY  
	# Load email template function
	app.emailTemplates = emailTemplates
	
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
	app.db.con = app.db.newCon(); #global, persistent connection, others can be made later
	
	app.db.con.on 'connect', ()->
		console.log '> DB: Global connection started'
	.on 'error', (err)->
		console.log '> DB: Global connection error: ' + err
	.on 'close', (hadError)->
		console.log '> DB: Global connection interrupted, reconnecting..'
		app.db.con.connect app.db.setup
	
	#setup models (must setup db first)
	app.Q = Q
	app.models = {}
	autoload 'app/models', app
	
	
	###
	# Sends email using the email-templates and mandrill libraries
	# @param eName = templateDirName (string)
	# @param eData = relevant sending data (see example)
	###
	app.emailTemplate = (eName,eData) ->
		# EXAMPLE eData
		# eData =
		# 	to_email: 'jrdbnntt@gmail.com'
		# 	from_email: 'account@hvzatfsu.com'
		# 	from_name: 'HvZ at FSU'
		# 	subject: 'Account Created!'
		# 	locals:
		# 		firstName: "Jared"
		# 		lastName: "Bennett"
		# 	success: function(to_email) #called after mandrill success
		# 	error: function(to_email) #called after mandrill error
				
		path = require 'path'
		templatesDir = path.resolve(__dirname,'..', 'emails')
		app.emailTemplates templatesDir,  (err, template) ->
			if err
				console.log err
			else
				locals = eData.locals
				Render = (locals) ->
					this.locals = locals
					this.send = (err,html,text) ->
						if !err
							console.log ' > Email-templates - Creation success'
							message = 
								html: html
								text: text
								subject: eData.subject
								from_email: eData.from_email
								from_name: eData.from_name
								to: [
									email: eData.to_email
									name: if eData.locals.firstName || 
										eData.locals.lastName then eData.locals.firstName + 
										' ' + eData.locals.lastName else eData.to_email
									type: 'to'
								]	
								
							app.mandrill.messages.send 'message': message, 'async': true, 
								(result) ->
									console.log ' > Mandrill - Email Sent Success - eData= ' + JSON.stringify eData
									if eData.success
										eData.success(eData.to_email)
								, (e) ->
									console.log ' > Mandrill - Error: ' + e.name + ' - ' + e.message
									if eData.error
										eData.error(eData.to_email)
						else
							console.log ' > Email-templates - Error: ' + err
							
					this.batch = (batch) ->
						batch this.locals, templatesDir, this.send
					
					return
				
				template eName, true, (err, batch) ->
					if this.err
						console.log this.err
					else
						render = new Render(locals)
						render.batch(batch)
					return
		return
	
	# Enforce ACL (needs to be last)
	# app.use acl
	
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
		
