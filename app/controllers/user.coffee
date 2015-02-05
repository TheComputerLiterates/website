module.exports = (app) ->
	class app.UserController
		@profile = (req, res) ->
			res.render 'user/profile',
				title: 'User - Profile'
		
		@forum = (req, res) ->
			res.render 'user/forum',
				title: 'User - Forum'
		
		@stats = (req, res) ->
			res.render 'user/stats',
				title: 'User - Statistics'