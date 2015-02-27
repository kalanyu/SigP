# SigP
Signal visualization tool on OSX for usb NI-DAQ devices. 

#Neccessary Prerequisites
- ni-daqmx base software
- the most recent version of Coreplot

You'll need to download the ni-daqmx base software that supports your version of the operating system provided by **National Instruments**
(see OS compatibility table [here](http://digital.ni.com/public.nsf/allkb/4EC97E7C5C93C31486256D1E00678E64)). **Core Plot** is a 2D plotting framework for Mac OS X and iOS. It is highly customizable and capable of drawing many types of plots. It is available for download [here](https://github.com/core-plot/core-plot).
#Compiling the project
Neccessary steps you will have to do involve:

1. Add nidaqmxbase.framework and nidaqmxbaselb.framework to this project
2. Add a reference to NIDAQmxbase.h to your project. (The file is located at /Applications/National Instruments/NI-DAQmx Base/includes)
3. Add a reference to the Core-plot project.
