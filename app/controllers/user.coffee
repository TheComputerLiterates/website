module.exports = (app) ->
	class app.UserController
		@profile = (req, res) ->

			res.render 'user/profile',
				title: 'User - Profile',
				firstname: 'Billy',
				lastname: 'Bob',
				hvzid: '0123456789',
				role: 'Player',
				email: 'billy@bob.com',
				phone: '850-555-6486'

		@forum = (req, res) ->
			res.render 'user/forum',
				title: 'User - Forum'
		
		@stats = (req, res) ->
			res.render 'user/stats',
				title: 'User - Statistics'
		
		@logout = (req,res)->
			req.session.user = undefined
			res.redirect '/'