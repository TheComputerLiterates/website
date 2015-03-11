module.exports = (app) ->
	class app.DataController
		@currentGame = (req, res)->
			res.send
				gameActive: true,
				playercount: 100,
				zombiecount: 70,
				humancount: 25