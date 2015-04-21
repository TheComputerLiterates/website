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

pt_fsu =  new google.maps.LatLng(30.442795, -84.298563)

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
	
	# Drawing
	# drawingManager = new google.maps.drawing.DrawingManager
	# 	drawingMode: google.maps.drawing.OverlayType.MARKER
	# 	drawingControl: true,
	# 	drawingControlOptions:
	# 		position: google.maps.ControlPosition.TOP_CENTER
	# 		drawingModes: [
	# 			google.maps.drawing.OverlayType.MARKER
	# 			google.maps.drawing.OverlayType.CIRCLE
	# 			google.maps.drawing.OverlayType.POLYGON
	# 			google.maps.drawing.OverlayType.POLYLINE
	# 			google.maps.drawing.OverlayType.RECTANGLE
	# 		]
	# 	markerOptions:
	# 		icon: 'img/icons/mapLocation-small.png'
	# 	circleOptions: 
	# 		fillColor: 'ffff00'
	# 		fillOpacity: .5
	# 		strokeWeight: 1
	# 		clickable: false
	# 		editable: true
	# 		zIndex: 1
			
	# drawingManager.setMap map
	
	# Place geopoints
	geopointIcon = 'img/icons/mapLocation-small.png'
	for gp in geopoints
		console.log 'GP=' + JSON.stringify gp
		point = new google.maps.Marker
			position: new google.maps.LatLng gp.latitude, gp.longitude
			map: map
			icon: geopointIcon
	for gf in geofences
		console.log 'GF=' + JSON.stringify gf
		fence = new google.maps.Circle
			strokeColor: gf.color
			strokeWeight: 0
			fillColor: gf.color
			fillOpacity: 0.35
			center: new google.maps.LatLng gf.latitude, gf.longitude
			radius: gf.radius
			map: map
			


google.maps.event.addDomListener(window, 'load', initMap);

