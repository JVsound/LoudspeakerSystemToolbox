function driver = createTestDriver
%CREATETESTDRIVER Driver of the tests: a B&C 21SW152-8 with the values of its datasheet
%   driver = createTestDriver returns a comp.Driver with the Thiele-Small parameters, the voice coil inductance and
%   the limits of the B&C 21SW152-8, from the datasheet B&C 21SW152-8.pdf next to this file. All tests use this
%   driver; a test that needs other values changes them on the returned driver.

driver = comp.Driver;
driver.Re = 6;
driver.Le = 2.2e-3;
driver.Qes = 0.38;
driver.Qms = 6.4;
driver.Fs = 32;
driver.Sd = 1680e-4;
driver.Vas = 200e-3;
driver.Znom = 8;
driver.Zmin = 7;
driver.Pnom = 2000;
driver.Pcont = 4000;
driver.Xmax = 15e-3;
driver.Xvar = 16e-3;
end
