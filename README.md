# DIRTclust 
DIRTclust is a pipeline to clustering root architecture shapes after Digital Image of Root Traits (DIRT) software. 
The usage is 
1. Git clone this repository 
2. Open a terminal, change to this repository
3. run docker run -it -v $(pwd):/opt/DIRTclust computationalplantscience/dirtclust bash 
4. run the script N_TRIAL_KMEANS=25(any number of clustering  you want to run) N_TRIAL_KNEEDLE=25 (any number of the kneedle algorithm you want to test)  N_CLUSTER=25 (any number of clusters you want specify) INPUT=/opt/DIRTclust/DIRTtest.csv (the path for your dirtoutput) WORKDIR=/opt/DIRTclust ./wrapper.sh
