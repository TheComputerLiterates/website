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
		
	return hvz
