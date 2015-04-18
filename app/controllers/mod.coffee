module.exports = (app) ->
	class app.ModController
		@index = (req, res) ->
			res.render 'mod/index',
				title: 'Mod Tools - Home'
		

		@info = (req, res) ->
			res.render 'mod/info',
				title: 'Mod Tools - Edit Info'
		
		@game = (req, res) ->
			res.render 'mod/game',
				title: 'Mod Tools - Current Game'
		
		########################################################################
		# USER MANAGEMENT
		
		# Main Page
		@users = (req, res) ->
			p = app.models.User.getAllBasic()
			p.then (userData)->
				console.log 'Success getting users!'
				
				# Get counts
				counts = 
					user: 0
					active: 0
					human: 0
					zombie: 0
					OZ: 0
					mod: 0
				
				for user in userData
					switch user.role
						when 'U' then ++counts.user
						when 'H' then ++counts.human
						when 'Z' then ++counts.zombie
						when 'O' then ++counts.OZ
						when 'M' then ++counts.mod
					
						
					if user.active == 0
						user.active = 'N'
					else
						++counts.active
						user.active = 'Y'
					
						
				res.render 'mod/users',
					title: 'Mod Tools - Manage Users'
					userData: userData
					counts: counts
			, (err)->
				console.log 'Error getting users'
		
		@users_submit = (req, res)->
			console.log 'BODY= ' + app.util.inspect req.body
			if req.body.action? &&
			req.body.userId?
				switch req.body.action
					when 'changeRole'		#switch role to ad.roleId
						if req.body.roleId?
							p = app.models.User.setRole req.body.userId, req.body.roleId
							p.then ()->
								res.send
									success: true
							, (err)->
								res.send
									success: false
									msg: 'Saving error: ' + err
						else
							res.send
								success: false
								msg: 'Invalid parameters'
							
					when 'activate'
						p = app.models.User.setActive req.body.userId, true
						p.then ()->
							# TODO - Send email notification
							res.send
								success: true
						, (err)->
							res.send
								success: false
								msg: 'Saving error: ' + err
					when 'deactivate'
						p = app.models.User.setActive req.body.userId, false
						p.then ()->
							# Now reset back to user role
							p = app.models.User.setRole req.body.userId, app.hvz.roles.USER.id
							p.then ()->
								res.send
									success: true
							, (err)->
								res.send
									success: false
									msg: 'Saving error: ' + err
						, (err)->
							res.send
								success: false
								msg: 'Saving error: ' + err
					when 'flag'				#set flag level to ad.flag
						if req.body.flag?
							res.send
								success: false
								msg: 'NOT IMPLEMENTED YET'
						else
							res.send
								success: false
								msg: 'Invalid parameters'
					when 'comment'			#set comment to ad.comment
						if req.body.comment?
							res.send
								success: false
								msg: 'NOT IMPLEMENTED YET'
						else
							res.send
								success: false
								msg: 'Invalid parameters'
					when 'edit'
						res.send
							success: false
							msg: 'NOT IMPLEMENTED YET'
					when 'delete'
						p = app.models.User.delete req.body.userId
						p.then (success) ->
							res.send
								success: success
						, (err) ->
							res.send
								success: false
								msg: err

					else
						res.send
							success: false
							msg: 'Invalid action'
			else
				res.send
					success: false
					msg: 'Invalid parameters'
		
		########################################################################
		# DEVELOPMENT
		
		# Main page
		@dev = (req, res) ->
			title = 'Mod Tools - Develop Games'
			gDateFormat = 'MM/DD/YY'
			mDateFormat = 'MM/DD/YY HH:mm a'
			games = []
			missions = []
			
			# Load mission and game data
			p = app.models.Game.getAll()
			p.then (gameData)->
				games = gameData
				
				# Shorten description to 100 chars
				for game in games
					game.startDate = game.startDate.format(gDateFormat)
					game.endDate = game.endDate.format(gDateFormat)
					# Shorten description
					if game.description.length >= 100
						game.description = game.description.substr 0, 100
						game.description += '[...]'
					
					# Get status
					
					
					
				
				
				p2 = app.models.Mission.getAll()
				p2.then (missionData)->
					missions = missionData
					
					for mission in missions
						mission.startDate = mission.startDate.format(mDateFormat)
						mission.endDate = mission.endDate.format(mDateFormat)
						# Shorten description
						if mission.description.length >= 100
							mission.description = mission.description.substr 0, 100
							mission.description += '[...]'
					
					
					console.log 'Success!'
					res.render 'mod/dev',
						title: title
						games: games
						missions: missions
						
				, (err)->
					console.log 'ERROR: Unable to get missions. ' + err
					res.render 'mod/dev',
						title: title
						games: games
						missions: missions
			, (err)->
				console.log 'ERROR: Unable to get games. ' + err
				res.render 'mod/dev',
					title: title
					games: games
					missions: missions
			
		@devCreateMission = (req, res) ->
			view = 'mod/dev/createMission'
			title = 'Mod Tools - Develop Games - Create New Mission'
			
			# Get game list
			p = app.models.Game.getAllTitles()
			p.then (games)->
				res.render view,
					title: title
					games: games
					roles: app.hvz.roles
					
			, (err)->
				res.render view,
					title: title
					games: null
			
			
			
		@devCreateMission_submit = (req, res) ->
			#TODO - form validation
			if req.body.gameId? &&
			req.body.assignedTo? &&
			req.body.visibility? &&
			req.body.title? &&
			req.body.description? &&
			req.body.startDate? &&
			req.body.endDate?
				missionData = 
					gameId: req.body.gameId
					roleId: req.body.assignedTo
					visibility: req.body.visibility		#parsed in model
					title: req.body.title
					description: req.body.description
					startDate: req.body.startDate
					endDate: req.body.endDate
								
				p = app.models.Mission.createNew missionData
				p.then ()->
					res.send
						success: true
				, (err)->
					res.send
						success: false
						msg: 'Creation Error: ' + err
				
			else
				res.send 
					success: false
					msg: 'Missing required fields'
			
		@devCreateGame = (req, res) ->
			res.render 'mod/dev/createGame',
				title: 'Mod Tools - Develop Games - Create New Game'
		@devCreateGame_submit = (req, res) ->
			#TODO - form validation
			if req.body.title? &&
			req.body.description? &&
			req.body.startDate? &&
			req.body.endDate?
				gameData = 
					title: req.body.title
					description: req.body.description
					startDate: req.body.startDate
					endDate: req.body.endDate
				
				console.log 'DATA= ' + app.util.inspect gameData
				
				p = app.models.Game.createNew gameData
				p.then ()->
					res.send
						success: true
				, (err)->
					res.send
						success: false
						msg: 'Creation Error: ' + err
				
			else
				res.send 
					success: false
					msg: 'Missing required fields'
			
		@devEditMission = (req, res) ->
			res.render 'mod/dev/editMission',
				title: 'Mod Tools - Develop Games - Edit Mission'
		@devEditMission_submit = (req, res) ->
			res.send 
				success: true
				
		@devEditGame = (req, res) ->
			res.render 'mod/dev/editGame',
				title: 'Mod Tools - Develop Games - Edit Game'
		@devEditGame_submit = (req, res) ->
			res.send 
				success: true
			
			