###
	Adds a bunch of error codes for easy reference and consistency

###

module.exports = 
	PAGE_NOT_FOUND: 404

	INVALID_LOGIN: 1000
	USER_ID_NOT_FOUND: 1001
	INVALID_HVZID: 1002

	GET_GAME_ERROR: 1100
	GAME_NOT_FOUND: 1101
	GET_MISSION_ERROR: 1102
	MISSION_NOT_FOUND: 1103

	CR_NOT_FOUND: 1200
	

	db:
		CONNECTION: 9000
		EXECUTION: 9001		#sql problems
		INPUT: 9002				#user input problems

	INVALID_PARAMETERS: 8000
	INVALID_PARAMETERS_TEXT: 'Invalid Parameters'
	