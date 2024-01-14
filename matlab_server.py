from flask import Flask
import satTest
import parse_data

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello world"

@app.route('/satTest')
def run_satTest():
    # arguments? default arg values?
    # run satTest and then
    data = parse_data.run_satTest()
    return data

if __name__ == "__main__":
    # run the flask server
    app.run()