#!/bin/bash

#start the nodes
function start() {
	CURRENT_UID=$(id -u):$(id -g) docker-compose up
}

#stop the nodes
function stop(){
	CURRENT_UID=$(id -u):$(id -g) docker-compose down
}	

