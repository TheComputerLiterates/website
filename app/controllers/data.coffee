module.exports = (app) ->
	class app.DataController
		@getGameStatus = (req, res)->
			app.models.Game.getGameStatus()
			.then (data)->
				res.send
					success: true
					data: data 
			, ()->
				console.log 'Unable to get game status'
				res.send
					success: false