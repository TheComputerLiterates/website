###
# Global Variables (Shown throughout the site)

###

module.exports = (app) ->
	currentGame:
		active: false
		humans: app.models.User.getRoleCount 2
		.then (count) ->
			app.global.currentGame.humans = count
		zombies: app.models.User.getRoleCount 3
		.then (count) ->
			app.global.currentGame.zombies = count	
	