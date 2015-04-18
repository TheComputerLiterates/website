# Database constants to avoid spelling errors

module.exports = (app) ->
	app.models.C =
		#tables
		TNAME:
			user: 'user'
			role: 'role'
			
			forum_post: 'forum_post'
			forum_thread: 'forum_thread'
			clarification_request: 'clarification_request'
			clarification_request_comment: 'clarification_request_comment'
			
			geopoint: 'geopoint'
			geofence: 'geofence'
			user_geopoint: 'user_geopoint'
			roles_seeing_geopoints: 'roles_seeing_geopoints'
			roles_affecting_geofences: 'roles_affecting_geofences'
			
			player_kill: 'player_kill'
			game: 'game'
			mission: 'mission'
			roles_in_missions: 'roles_in_missions'
			users_in_missions: 'users_in_missions'
			users_in_games: 'users_in_games'
			
			android_instance: 'android_instance'
			website_instance: 'website_instance'	# DEPRECATED
			
		
		# Views
		VNAME:
			user_credentials_with_role: 'user_credentials_with_role'
			user_profile_with_role: 'user_profile_with_role'
		
		# Routines
		RNAME:
			genUniqueHVZID: 'genUniqueHVZID'			#()
			createPlayerKill: 'createPlayerKill'	#(killerId, victimHVZID)
	
		
		