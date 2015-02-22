module.exports = (app) ->
	class app.DataController
		@currentGame = (req, res)->
			data = 
				gameActive: true,
				playercount: 100,
				zombiecount: 75,
				humancount: 25
			res.send data
				