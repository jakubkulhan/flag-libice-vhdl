# SDC file "DE2.sdc"
## DEVICE  "EP2C35F672C6"
set_time_format -unit ns -decimal_places 3
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } 
create_clock -name {CLOCK_27} -period 37.000 -waveform { 0.000 18.500 }
