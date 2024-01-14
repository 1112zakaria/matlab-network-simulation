from flask import Flask, request
import satTest
import parse_data

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello world"

def validate_satTest_args(snr, num_bits, mod_ord) -> dict:
    # returns **args dict
    args = {}
    if snr is not None:
        args['snr'] = int(snr)
    if num_bits is not None:
        args['num_bits'] = int(num_bits)
    if mod_ord is not None:
        args['mod_ord'] = int(mod_ord)
    return args

@app.route('/satTest', methods=['GET'])
def run_satTest():
    # arguments? default arg values?
    snr = request.args.get('snr')
    num_bits = request.args.get('numBits')
    mod_ord = request.args.get('modOrd')
    args = validate_satTest_args(snr, num_bits, mod_ord)
    # run satTest
    data = parse_data.run_satTest(**args)

    # FIXME: should I include configuration settings in the output?
    return data

if __name__ == "__main__":
    # run the flask server
    app.run()