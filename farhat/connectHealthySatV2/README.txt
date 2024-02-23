Files "testingSat.m" , "middleMan.m", "getPredicVal.m" and "satTest.m" should be in Ottawa_Canada folder.

middleMan code is responsible for checking which available satellites are best to be used at different times based on thershold calculations
testingSat code receives the list of good satellites from middle man code.
middleMan code calls getPredicVal code multiple number of times based on how many satellites are available to show different predic values at different times
satTest code gets called by testingSat code based on the number of healthy satellites to show communication data