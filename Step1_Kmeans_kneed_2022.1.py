#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 15 14:21:04 2020

@author: Limeng Xie 

The script is used to get the raw spectrum from DS curves. 

"""

from sklearn.cluster import KMeans
import pandas as pd
from kneed import KneeLocator
import numpy as np


# function to import DIRT format data, and return only the DS value for 10%-90% depth 
def inputdata_ds(file):
    data = pd.read_csv(file,index_col=False)
    data.head()
    dswithtag = data[['IMAGE_NAME','DS10','DS20','DS30','DS40','DS50','DS60','DS70','DS80','DS90']]
    ds = dswithtag.iloc[:,1:10]
    return ds  

# ** need to figure out what is the difference between these two function 
# function to import DIRT format data, and return only the DS value for 10%-90% depth and with imagename(root number)
def inputdata_dswithtag(file):
    data = pd.read_csv(file,index_col=False)
    data.head()
    dswithtag = data[['IMAGE_NAME','DS10','DS20','DS30','DS40','DS50','DS60','DS70','DS80','DS90']]
    return dswithtag


# decide how many clusters 
# function to determine which is optimal K number for clustering using Elbow menthod.
# Elbow method: one should choose a number of clusters so that adding another cluster doesn't give much better modeling of data
# Return to the max inertia result. 
# Percentage of variance explained is the ratio of the between-cluster variance to the total variance, also known as an F-test
def kneepoint_onetime(K,ds):
    withinVar=[]
    for k in range(1, K+1): 
        #print(k)
        # intial seeds with Kmeans++ algorithm and with the cluster number ranges from 1:K
        kmeansplusplus= KMeans(algorithm='lloyd',init= 'k-means++', max_iter=50, n_clusters=k,                
                    n_init=30, random_state=None)
        model=kmeansplusplus.fit(ds)
        #center=model.cluster_centers_
        #cluster_label=model.labels_
        #sum squared distance of samples to their closet cluster center, which is also within-cluster variance 
        inerita=model.inertia_
        withinVar.append(inerita)
        #print(withinVar)
    x=[j for j in range(1,K+1)] # K number 
    # S is sensitivity 
    kn=KneeLocator(x, withinVar, S=1, curve='convex', direction='decreasing',interp_method='polynomial')
    kneepoint=kn.knee
    return kneepoint
    
# n is the number of trials of kmeans++
# To get the most frequent knee point 
def chooseCluster_num(n_trial_kneedle,ncluster_test,ds):
    kneepointlist = []   
    for i in range (0,n_trial_kneedle):
        result = kneepoint_onetime(ncluster_test,ds)
        kneepointlist.append(result)
    # average knee point 
    cluster_num= int(max(kneepointlist,key=kneepointlist.count))
    return cluster_num
    

# function to run n trials of kmeans++ clustering and choose the best of trial of all the trials based on caliharascore
def kmeansplusplus(n_trial,n_trial_kneedle,ncluster_test,ds,dswithtag):
    tmp=[]
    cluster_num = chooseCluster_num(n_trial_kneedle,ncluster_test,ds)
    print("Elbow method say number of clusters should be:", cluster_num)
    for j in range (0, n_trial):
    # kmeans ++ clustering with the choosen number of clusters 
        kmeansplusplus= KMeans(algorithm='lloyd',init= 'k-means++', max_iter=50, n_clusters=cluster_num, n_init=30, random_state=None)
        model=kmeansplusplus.fit(ds)
        cluster_label=model.labels_.tolist()
        inerita=model.inertia_
        inerita=np.asarray(inerita).tolist()# change float type numpy array
        tmp.append((cluster_label,inerita))
    cols=['label','inertia']
    # create dataframe to store each run label and caliharascore 
    result=pd.DataFrame(tmp,columns=cols)
    #result_sorted=result.sort_values(by=['score'],ascending=False)
    # backward seletion 
    result_sorted=result.sort_values(by=['inertia'],ascending=True)
    #print(result_sorted)
    best_label=result_sorted.iloc[0,0]
    dswithtag['cluster_label']=best_label
    output=dswithtag
    return output
