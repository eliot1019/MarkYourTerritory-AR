# MarkYourTerritory-AR
Users are able to leave or "mark" the spot they are located at with a message. 
Any other user in that location will be able to see this message in real-time and concurrently add new messages to the virtual world. Users can move around and the app will constantly be pulling in other user's marks!


[Star Wars](starwars.jpg)
[Map](map.jpg)

The project uses ARKit and an open source ARKit-CoreLocation framework. 
This allowed us to be able to connect the user's location to pin their marked messages in an AR world. 

Firebase was used to store all our data related to a pin (user, latitude, longitude, data) and GeoFire, a Firebase extension, was used to store and retrieve latitude and longitude points.
For Geoqueries of a certain radius in our backend, we utilize the [Geohash algorithm] https://en.wikipedia.org/wiki/Geohash .

