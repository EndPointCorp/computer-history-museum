SHELL = /bin/sh

compile:
	cd master; zip ../lg-chm-master.kmz doc.kml images/* audio/* actions.yml queries.txt; cd ..
	cd center; zip ../lg-chm-center.kmz doc.kml images/*; cd ..
	cd slave; zip ../lg-chm-slave.kmz  doc.kml; cd ..
