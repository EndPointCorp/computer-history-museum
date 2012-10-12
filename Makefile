SHELL = /bin/sh

compile:
	zip lg-chm-master.kmz master/doc.kml master/images/* master/audio/* master/actions.yml master/queries.txt
	zip lg-chm-center.kmz center/doc.kml center/images/*
	zip lg-chm-slave.kmz  slave/doc.kml
