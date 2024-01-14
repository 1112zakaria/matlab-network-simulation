import pandas as pd
from pprint import pprint

PATH = "satTestTable.csv"
SATTEST_PATH = "satTestTable.csv"

class SatTestMapper:
    # object that contains data to send.
    def __init__(self, txData, txSig, awgnSig, therSig, phaseSig, rxData_1, rxData_2):
        self.txData = txData
        self.txSig = txSig
        self.awgnSig = awgnSig
        self.therSig = therSig
        self.phaseSig = phaseSig
        self.rxData_1 = rxData_1
        self.rxData_2 = rxData_2

    def toDict(self) -> dict:
        data = {}

        data['txData'] = self.txData

        real, imag = self.splitComplexNumber(self.txSig)
        data['txSig'] = {'real': real, 'imag': imag}

        real, imag = self.splitComplexNumber(self.awgnSig)
        data['awgnSig'] = {'real': real, 'imag': imag}

        real, imag = self.splitComplexNumber(self.therSig)
        data['therSig'] = {'real': real, 'imag': imag}

        real, imag = self.splitComplexNumber(self.phaseSig)
        data['phaseSig'] = {'real': real, 'imag': imag}

        data['rxData_1'] = self.rxData_1
        
        data['rxData_2'] = self.rxData_2

        return data

    def splitComplexNumber(self, n: str):
        num = complex(n.replace("i", "j"))
        return num.real, num.imag


def get_complex_number(val: str) -> complex:
    return complex(val.replace("i", "j"))

def run_satTest(snr=25, numBits=40, modOrd=64):
    # FIXME: put args as struct?
    # TODO: lock this function to single-thread access
    # call matlab function

    # read output
    return read_satTest()

def read_satTest() -> list[dict]:
    # FIXME: not reentrant/thread-safe
    # returns some usable JSON/dict data
    df = pd.read_csv(SATTEST_PATH)
    num_rows = len(df.index)
    row_data: list[dict] = []

    # iterate each row, for each time step, store each col value
    for i, j in df.iterrows():
        row_data.append(SatTestMapper(
            j['txData'], j['txSig'], j['awgnSig'], j['therSig'],
            j['phaseSig'], j['rxData_1'], j['rxData_2']
        ).toDict())
    return row_data

if __name__ == "__main__":
    dict_data = read_satTest()
    pprint(dict_data)