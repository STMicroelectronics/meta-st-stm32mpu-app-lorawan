# Copyright (C) 2019, STMicroelectronics - All Rights Reserved

SUMMARY = "Recipe to avoid demo_launcher application to start"

do_install_append () {
	chmod a-x ${D}${prefix}/local/weston-start-at-startup/start_up_demo_launcher.sh
}
