module.exports = (app) ->
	class app.GameController
		@index = (req, res) ->
			view = 'game/index'
			title = 'Current Game'
			gDateFormat = 'MMMM Do'
			mDateFormat = 'ddd h:mma'
			
			# Get current game information
			p = app.models.Game.getCurrentGame()
			p.then (gameData)->
				if gameData.gameId?
					console.log 'USER= ' + app.util.inspect req.session
					# Format game dates
					gameData.startDate = gameData.startDate.format gDateFormat
					gameData.endDate = gameData.endDate.format gDateFormat
					
					if req.session.user?
						#Grab all missions
						p2 = app.models.Mission.getMissionsByGameRole gameData.gameId, req.session.user.roleId 
						p2.then (missionData)->						
							#format mission data
							for m in missionData
								m.startDate = m.startDate.format mDateFormat
								m.endDate = m.endDate.format mDateFormat
								m.roleName = app.hvz.getRoleById(m.roleId).toUpperCase()
								
							res.render view, 
								success: true
								title: title
								gameData: gameData
								missionData: missionData
								
						, (err)->
							res.render view, 
								title: title
								success: false
								msg: 'Problem loading missions. ' + err
					else
						res.render view, 
							title: title
							gameData: gameData
							success: true
				else 
					res.render view, 
						title: title
						success: false
						msg: 'No game found'

			, (err)->
				res.render view, 
					title: title
					success: false
					msg: 'Problem loading current game. ' + err
				
		
		@kill = (req, res) ->
			res.render 'game/kill',
				title: 'Game - Report Kill'
		
		@map = (req, res) ->
			res.render 'game/map',
				title: 'Game - Dynamic Map'
		
		@missions = (req, res) ->
			res.render 'game/missions',
				title: 'Game - Missions'