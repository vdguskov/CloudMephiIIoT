import requests
import json

def geo_data():
    url_geo = 'http://api.geonames.org/findNearbyJSON?lat={}&lng={}&username=VDGUSKOV'
    res = requests.get('http://10.20.14.39:443/get_lidar').text
    geo = []
    for d in json.loads(res):
        place = requests.get(url_geo.format(d[2], d[1])).text
        place_name = json.loads(place)['geonames'][0]['name']
        geo.append(place_name)
    return geo