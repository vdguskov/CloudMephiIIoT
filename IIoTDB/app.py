from flask import Flask, render_template, request, Response, jsonify
import datetime
import db
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app, allow_headers=['Content-Type', 'Access-Control-Allow-Origin',
                         'Access-Control-Allow-Headers', 'Access-Control-Allow-Methods'])

mode = 'auto'
move = 'default'

@app.route('/')
def hello_world():
    return render_template("index.html")


@app.route('/get_lidar', methods=['GET'])
def get_lidar():
    data = db.get_lidar()
    return jsonify(data)

@app.route('/add_coord', methods=['POST'])
def add_coord():
    lon = request.args.get('lon')
    lat = request.args.get('lat')
    res = db.add_coordinate(lon, lat)
    if res:
        return 'Added new coordination'
    else:
        return res

@app.route('/condition', methods=['POST'])
def change_condition():
    global mode
    global move
    message = json.loads(request.data)
    mode = message['mode']
    move = message['move']
    data = db.db_log(mode, move, datetime.datetime.now(), 'change_condition')
    if data is True:
        return f'Новый режим: {mode}' \
               f'Новое направление {move}'
    else:
        return data

@app.route('/get_log', methods=['GET'])
def get_log():
    return jsonify(db.get_log())

if __name__ == '__main__':
    app.run(host='0.0.0.0')
