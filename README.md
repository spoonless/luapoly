**luapoly** is an implementation of the [ear clipping method](https://en.wikipedia.org/wiki/Polygon_triangulation#Ear_clipping_method) for polygon triangulation.

You can draw a polygon by left clicking on the display area to add points.
Right clicking creates the last edge of the polygon (from the last point to the first one) and runs the triangulation algorithm.
At any time backspace can be used to delete points in the reverse order.

GUI is based on [Löve 11.x](https://love2d.org/)

To run **luapoly** (from the project parent directory):

	love luapoly

If you like, you can pass as argument a file path to load a polygon. A polygon file is a text file containing comma separated list of x,y coordinates.

	love luapoly luapoly/samples/poly.poly

To run unit tests (from the project directory):

	lua test_poly.lua
	lua test_circular_table.lua

**luapoly** is compatible with lua 5.1.

