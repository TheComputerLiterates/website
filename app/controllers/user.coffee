module.exports = (app) ->
	class app.UserController
		@profile = (req, res) ->

			userRole

			for roles, role of app.locals.hvz.roles
				if role.id == parseInt req.session.user.roleId
					userRole = role.name
					break

			res.render 'user/profile',
				title: 'User - Profile'
				firstname: req.session.user.firstName
				lastname: req.session.user.lastName
				email: req.session.user.email
				hvzid: req.session.user.HVZID
				role: userRole
				

		@forum = (req, res) ->
			res.render 'user/forum',
				title: 'User - Forum'
		
		@stats = (req, res) ->
			res.render 'user/stats',
				title: 'User - Statistics'
		
		@logout = (req, res)->
			req.session.user = undefined
			res.redirect '/'
			
		########################################################################
		# Clarification requests
		@cRequestCreate = (req, res)->
			title = 'User - Clarification Request Form'
			view = 'user/cRequestCreate'
			
			# Construct the game + mission list if player
			if req.session.user &&
			req.session.user.roleId >= app.hvz.roles.HUMAN.id
				# Construct them
				app.models.Game.getAllTitles()
				.then (games)->
					app.models.Mission.getTitlesByRole(req.session.user.roleId)
					.then (missions)->
						
						# Add role name befor each title
						for mission in missions
							mission.title = app.hvz.getRoleById(mission.roleId) +
								" - " + mission.title
						
						res.render view,
							title: title
							gameData: games
							missionData: missions
					, (err)->
						res.render view,
							title: title
							gameData: games
							missionData: {}
				, (err)->
					res.render view,
						title: title
						gameData: {}
						missionData: {}
			else 
				res.render view,
					title: title
					gameData: {}
					missionData: {}
		
		@cRequestCreate_submit = (req, res)->
			if req.body.subject? &&
			req.body.description? &&
			req.body.personal?
				
				app.models.ClarificationRequest.createNew 
					subject: req.body.subject
					description: req.body.description
					personal: req.body.personal
					gameId: req.body.gameId				#can be undefined
					missionId: req.body.missionId		#can be undefined
					openUserId: req.session.user.userId
				.then ()->
					res.send
						success: true
						body: {}	
				, (err)->
					res.send
						success: false
						body:
							error: err
							code: app.errors.db.EXECUTION
					
			else
				res.send
					success: false
					body:
						error: 'Invalid input'
						code: app.errors.db.INPUT
						
		@cRequestView = (req, res)->
			title = 'User - Clarification Requests'
			view = 'user/cRequestView'
			
			res.render view,
				title: title
		
		@cRequestView_submit = (req, res)->
			res.send
				success: true
				body: {}	