module.exports = (app) ->
	class app.ModController
		@index = (req, res) ->
			res.render 'mod/index',
				title: 'Mod Tools - Home'
		
		@dev = (req, res) ->
			res.render 'mod/dev',
				title: 'Mod Tools - Develop Games'
				
		@game = (req, res) ->
			res.render 'mod/game',
				title: 'Mod Tools - Current Game'
		
		@info = (req, res) ->
			res.render 'mod/info',
				title: 'Mod Tools - Edit Info'
		
		@users = (req, res) ->
			res.render 'mod/users',
				title: 'Mod Tools - Manage Users'
				