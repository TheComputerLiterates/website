###
For '/mod/users'

Handles user management.

Dependencies:
	jQuery
	socket.io
	AngularJS 

###

ModApp
HVZApp.controller 'Mod_Users', ($scope, $http) ->
	console.log 'USERDATA: ' + JSON.stringify $scope.userData, undefined, 2
