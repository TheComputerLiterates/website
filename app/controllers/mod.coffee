module.exports = (app) ->
	class app.ModController
		@index = (req, res) ->
			res.render 'mod/index',
				title: 'Mod Tools - Home'
		
				
		@game = (req, res) ->
			res.render 'mod/game',
				title: 'Mod Tools - Current Game'
		
		@info = (req, res) ->
			res.render 'mod/info',
				title: 'Mod Tools - Edit Info'
		
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
			
		########################################################################
		# DEVELOPMENT
		
		# Main page
		@dev = (req, res) ->
			title = 'Mod Tools - Develop Games'
			games = []
			missions = []
			
			# Load mission and game data
			p = app.models.Game.getAll()
			p.then (gameData)->
				games = gameData
				
				# Shorten description to 100 chars
				for game in games
					
					# Shorten description
					if game.description.length >= 100
						game.description = game.description.substr 0, 100
						game.description += '[...]'
					
					# Get status
					
					
					
				
				
				p2 = app.models.Mission.getAll()
				p2.then (missionData)->
					missions = missionData
					
					for mission in missions
						
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
			req.body.visibility? &&
			req.body.title? &&
			req.body.description? &&
			req.body.startDate? &&
			req.body.endDate?
				missionData = 
					gameId: req.body.gameId
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
			
			