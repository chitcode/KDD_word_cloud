#!/usr/bin/env python

from bottle import route, run, template, get,post, debug,static_file,request

import pandas as pd
import numpy as np
import re
import json

debug(True)

# this will be the dictionary returned by the ajax call.
# Bottle convert this in a json compatibile string.

#items = {1: 'first item', 2: 'second item'}

# a simple json test main page


@route('/')
def jsontest():
    return template('home')

@route('/static/<filename>')
def serve_static(filename):
    return static_file(filename, root='static')
    
    
@route('/getUpdatedData',method='GET')
def get_updated_data():
    selected_cols = request.query.columns.split(',')     
    dataset = pd.read_csv('data/essay_sample.csv') # OPERATIONS, BUSINESS, PEOPLE
       
    sel_cols = [i for i in np.arange(len(dataset.columns)) if dataset.columns[i] in selected_cols]
    
    dataset = dataset.ix[:,sel_cols]
    
    dataset = dataset.fillna(" ")
    
    dataset = dataset.apply(lambda x : " ".join(x), axis = 0)
    
    dataset_words = []
    for i in np.arange(len(dataset)):
        dataset_words = dataset_words+dataset[i].split(' ')
    
    
    dataset_words = ["".join(re.sub('[^A-Za-z0-9]+'," ",w.lower().strip())) for w in dataset_words]
    
    stop_words =  'I,a,about,an,and,are,any,as,at,be,by,com,can,for,etc,from,has,have,\
    how,in,is,it,more,not,of,on,or,should,that,the,\
    there,this,to,up,was,what,when,where,who,will,with,the,there,www,company,people'
    stop_words = stop_words.lower()
    stop_words = stop_words.split(",")
    
      
    dataset_words = [w for w in dataset_words if w not in stop_words]
    dataset_dict = json.dumps(word_count(dataset_words))
    
    dataset_dict = word_count(dataset_words)
    dataset_json_list = dict_list(dataset_dict)
    
    
    return json.dumps(dataset_json_list)
    
def word_count(word_list):
    word_dict = {}
    for words in word_list:
        words = words.strip()
        if words in word_dict:
           word_dict[words] += 1
        else:
           word_dict[words] = 1
    return word_dict

def dict_list(words_count_dict):
    dict_json_list = [{"text":k,"size":words_count_dict[k]} for k in words_count_dict.keys() if k != ""]
    return dict_json_list

@route('/test')
def testing():
    return 'Testing page'

run(host='0.0.0.0', port=8081,debug=True, reloader=True)

# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
