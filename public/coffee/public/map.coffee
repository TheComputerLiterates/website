###
	For /map
		- displays custom google map
	Data Variables
		geofences
		geopoints
###
console.log geopoints
console.log geofences

##############################################################################
# Displaying the map
# http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html?utm_medium=twitter

ID_MAP_CANVAS = 'map-canvas'
geopointIcon = 'img/icons/mapLocation-small.png'

pt_fsu =  new google.maps.LatLng(30.442795, -84.298563)
map = null
mapCircles = []
mapMarkers = []

# Uses current state of geopoints and geofences
placeMapData = ()->
	# Delete any old ones
	i = 0
	console.log mapCircles.toString()
	for c in mapCircles
		c.setMap null
	for m in mapMarkers
		m.setMap null
		
	mapCircles = []
	mapMarkers = []
	mapCircles.toString()
	console.log '---------------------'
	for gp in geopoints
		console.log 'GP=' + JSON.stringify gp
		mapMarkers.push new google.maps.Marker
				position: new google.maps.LatLng gp.latitude, gp.longitude
				map: map
				icon: geopointIcon
	for gf in geofences
		console.log 'GF=' + JSON.stringify gf
		mapCircles.push new google.maps.Circle
			strokeColor: gf.color
			strokeWeight: 0
			fillColor: gf.color
			fillOpacity: 0.35
			center: new google.maps.LatLng gf.latitude, gf.longitude
			radius: gf.radius
			map: map

initMap = ()->
	CUSTOM_MAPTYPE_ID = 'custom_style'
	featureOpts = [
		{
			stylers: [
				{ hue: '#2e2b21' }
				{ visibility: 'simplified' }
				{ gamma: 0.5 }
				{ weight: 1 }
				{ invert_lightness: false }
			]
		}
		{
			elementType: 'labels'
			stylers: [
				{ visibility: 'off' }
			]
		}
		{
			featureType: 'water'
			stylers: [
				{ color: '#9cbebd' }
			]
		}
	]
	
	styledMapOptions =
		name: 'Custom Style'
		
	customMapType = new google.maps.StyledMapType featureOpts, styledMapOptions
	
	mapOptions = 
		center: pt_fsu
		zoom: 16
		# mapTypeControlOptions:
		# 	mapTypeIds: [google.maps.MapTypeId.ROADMAP, MAPTYPE_ID]
		# mapTypeId: MAPTYPE_ID
		disableDefaultUI: true
		mapTypeControl: true
		mapTypeControlOptions:
			style: google.maps.MapTypeControlStyle.DEFAULT
			mapTypeIds: [
				CUSTOM_MAPTYPE_ID
				google.maps.MapTypeId.HYBRID
			]
		
	map = new google.maps.Map document.getElementById(ID_MAP_CANVAS), mapOptions
	
	map.mapTypes.set CUSTOM_MAPTYPE_ID, customMapType
	map.setMapTypeId CUSTOM_MAPTYPE_ID
	
	# Place geopoints
	placeMapData()


google.maps.event.addDomListener(window, 'load', initMap);


reloadData = ()->
	console.log 'Reloading...'
	$.ajax
		type: 'POST'
		url: '/map/reload'
		data: JSON.stringify {}
		contentType: 'x-www-form-urlencoded'
		success: (res) ->
			if res.success
				geofences = res.body.geofences
				geopoints = res.body.geopoints
				placeMapData()
				console.log 'Reload success!'
			else
				console.log 'Error loading data: ' + res.body.error
				return
		error: () ->
			console.log 'Error asking for data'
			return

setInterval ()->
	reloadData()
, 30000 #60000 = 1m
