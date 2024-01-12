import satTest

if __name__ == "__main__":
    print('Started matlab engine...')

    analyzer = satTest.initialize()
    analyzer.satTest()
    
    print('Quit matlab engine!')
    pass