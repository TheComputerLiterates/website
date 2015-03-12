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
			if req.session.user? && req.session.user.roleId > 0
				# already logged in
				res.redirect '/user/profile'
			else
				res.render 'public/login',
					title: 'Login' 
		
		#post
		@login_submit = (req, res) ->
			#TODO form validation
			if req.body.email? &&
			req.body.password?
				loginData = 
					email: req.body.email
					password: req.body.password
					
				#check creds
				p = app.models.User.checkLogin loginData
				p.then (userData)->
					console.log 'User login success: ' + userData.email
					#save info in session
					req.session.user = userData
						
					res.send
						success: true
						msg: ""
					
				, (err)->
					res.send
						success: false
						msg: err
				

		# SIGNUP ###############################################################
		# Page (GET)
		@signup = (req, res) ->
			res.render 'public/signup',
				title: 'Sign Up'
		
		# POST
		@signup_submit = (req,res) ->
			#TODO form validation
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
							
							# Send email
							app.emailTemplate 'accountCreated', 
								to_email: userData.email
								from_email: 'do_not_reply@hvzatfsu.com'
								from_name: 'HvZ @ FSU'
								subject: 'Account Created!'
								locals:
									firstName: userData.first_name
									lastName: userData.last_name
							
							console.log 'rawr'
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
			