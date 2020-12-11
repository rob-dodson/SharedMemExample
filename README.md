# Simple Shared Memory Example Code for macOS

Here is a Swift project that shows how to used Unix shared memory. 
Compile and run it from Xcode. Look for output on the console.

To compile the C version: run make from the command line.
To run it: ./shm server &lt;msg&gt; | client | delete

Remember to delete the shared memory segment when done.

Xcode Swift code completion is helpful in figuring out how to call C lib functions.
You may need a bridging header to #import headers for C lib stuff.

