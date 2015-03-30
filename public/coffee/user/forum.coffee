Forum = angular.module "Forum", []

Forum.controller "ForumController", ($scope) ->
	$scope.posts = [
		{
			postID: 0,
			title: "Post 0 - Level 0",
			parent: null,
			description: "Describe 1"
		},
		{
			postID: 1,
			title: "Post 0 - Level 1",
			parent: 0,
			description: "Describe 2"
		},
		{
			postID: 2,
			title: "Post 1 - Level 0",
			parent: null,
			description: "Describe 3"
		}
	]

