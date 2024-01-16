import pandas as pd
from pprint import pprint
import satTest

PATH = "satTestTable.csv"
SATTEST_PATH = "satTestTable.csv"

IMAG_KEY = 'imaginary'
REAL_KEY = 'real'

# initialize matlab engines
print('initializing matlab engines')
satTest_handler = satTest.initialize()

class SatTestMapper:
    # object that contains data to send.
    def __init__(self, rowIdx: int, row: pd.Series):
        self.rowIdx = rowIdx
        self._parseRow(row)

    def _parseRow(self, row: pd.Series):
        self.txData = row['txData']
        self.txSig = row['txSig']
        self.awgnSig = row['awgnSig']
        self.therSig = row['therSig']
        self.phaseSig = row['phaseSig']
        self.rxData = None

        # determine if 4, 2, or 1 column
        # FIXME: ask Richard if 4 is the max # bits the QAM demodulation thing reaches
        rxData = row['rxData'] if 'rxData' in row else None
        rxData_1 = row['rxData_1'] if 'rxData_1' in row else None
        rxData_2 = row['rxData_2'] if 'rxData_2' in row else None
        rxData_3 = row['rxData_3'] if 'rxData_3' in row else None
        rxData_4 = row['rxData_4'] if 'rxData_4' in row else None
        if 'rxData_4' in row:
            # 4 columns
            self.rxData = [rxData_1, rxData_2, rxData_3, rxData_4]
        elif 'rxData_2' in row:
            # 2 columns
            self.rxData = [rxData_1, rxData_2]
        else:
            # 1 column
            self.rxData = [rxData]

    def toDict(self) -> dict:
        data = {}

        data['rowIdx'] = self.rowIdx

        data['txData'] = self.txData

        real, imag = self.splitComplexNumber(self.txSig)
        data['txSig'] = {REAL_KEY: real, IMAG_KEY: imag}

        real, imag = self.splitComplexNumber(self.awgnSig)
        data['awgnSig'] = {REAL_KEY: real, IMAG_KEY: imag}

        real, imag = self.splitComplexNumber(self.therSig)
        data['therSig'] = {REAL_KEY: real, IMAG_KEY: imag}

        real, imag = self.splitComplexNumber(self.phaseSig)
        data['phaseSig'] = {REAL_KEY: real, IMAG_KEY: imag}

        data['rxData'] = self.rxData

        return data

    def splitComplexNumber(self, n: str):
        num = complex(n.replace("i", "j"))
        return num.real, num.imag

def run_satTest(snr=25.0, num_bits=40.0, mod_ord=64.0):
    # FIXME: put args as struct?
    # TODO: lock this function to single-thread access
    # call matlab function
    satTest_handler.satTest(snr, num_bits, mod_ord)

    # read output
    return read_satTest()

def read_satTest() -> list[dict]:
    # FIXME: not reentrant/thread-safe
    # returns some usable JSON/dict data
    df = pd.read_csv(SATTEST_PATH)
    num_rows = len(df.index)
    row_data: list[dict] = []

    # iterate each row, for each time step, store each col value
    idx = 1 # FIXME: is there a single-source way of getting idx?
    for i, j in df.iterrows():
        row_data.append(SatTestMapper(idx, j).toDict())
        idx += 1
    return row_data

if __name__ == "__main__":
    dict_data = read_satTest()
    pprint(dict_data)