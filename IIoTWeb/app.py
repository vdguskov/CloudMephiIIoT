from flask import Flask, render_template, request, Response, jsonify, after_this_request
import get_req
import re

with open('ip.txt') as f:
    ip = re.sub(r'\s', '', f.readline().replace(' ', ''))

app = Flask(__name__)

@app.route('/')
def hello_world():
    return render_template("index.html", ip=ip)

@app.route('/lidar', methods=['GET'])
def lidar():
    return str(get_req.geo_data())

if __name__ == '__main__':
    app.run(host='0.0.0.0')
