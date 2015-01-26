module.exports = (app) ->
	class app.GameController
		@index = (req, res) ->
			res.render 'game/index',
				title: 'Game - Home' # TODO: replace 'Game' with Zombie/Human
		
		@kill = (req, res) ->
			res.render 'game/kill',
				title: 'Game - Report Kill'
		
		@map = (req, res) ->
			res.render 'game/missions',
				title: 'Game - Dynamic Map'
		
		@missions = (req, res) ->
			res.render 'game/missions',
				title: 'Game - Missions'