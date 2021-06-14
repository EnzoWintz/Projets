#!/bin/bash

#suppression des containers qui ne seront pas utilisés à cette étape

docker rm $(docker ps -a -f status=created -q)
 
