###
hvz specific constants/config vars

###

module.exports = (app) ->
	return construct app
construct = (app)->
	hvz = 
		roles:	# same as role_id in DB
			GUEST:
				id: 0
				name: 'Guest'
			USER:
				id: 1
				name: 'User'
			HUMAN:
				id: 2
				name: 'Human'
			ZOMBIE:
				id: 3
				name: 'Zombie'
			OZ:
				id: 4
				name: 'OZ'
			MODERATOR:
				id: 5
				name: 'Moderator'
		specialUserIds:	[0,1]							#cannot delete or change role
	
	hvz.getRoleById = (id)->
		for key, obj of hvz.roles
			if obj.id == id
				return obj.name
		return '?'
	
	# Pulls from db to get short game status. TODO
	hvz.getGameStatus = ()->
		humans = null
		zombies = null

		# My little attempt at it
		app.models.User.getRoleCount 2
		.then (count) ->
			humans = count
		app.models.User.getRoleCount 3
		.then (count) ->
			zombies = count

		return 'GameName | ' + humans + ' Humans ' + zombies + ' Zombies '
		
		
	return hvz
