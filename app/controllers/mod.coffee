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
				
				p2 = app.models.Mission.getAll()
				p2.then (missionData)->
					missions = missionData
					
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
			res.render 'mod/dev/createMission',
				title: 'Mod Tools - Develop Games - Create New Mission'
		@devCreateMission_submit = (req, res) ->
			res.send true
			
		@devCreateGame = (req, res) ->
			res.render 'mod/dev/createGame',
				title: 'Mod Tools - Develop Games - Create New Game'
		@devCreateGame_submit = (req, res) ->
			res.send true
			
		@devEditMission = (req, res) ->
			res.render 'mod/dev/editMission',
				title: 'Mod Tools - Develop Games - Edit Mission'
		@devEditMission_submit = (req, res) ->
			res.send true
				
		@devEditGame = (req, res) ->
			res.render 'mod/dev/editGame',
				title: 'Mod Tools - Develop Games - Edit Game'
		@devEditGame_submit = (req, res) ->
			res.send true
			
			