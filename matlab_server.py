from flask import Flask
import satTest

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello world"

@app.route('/satTest')
def run_satTest():
    # arguments? default arg values?
    # run satTest and then
    return "success"

if __name__ == "__main__":
    # run the flask server
    app.run()