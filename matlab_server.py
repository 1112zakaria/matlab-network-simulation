import matlab.engine

if __name__ == "__main__":
    eng = matlab.engine.start_matlab()
    print('Started matlab engine...')
    eng.quit()
    print('Quit matlab engine!')
    pass