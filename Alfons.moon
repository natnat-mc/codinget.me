moonbuild = require 'moonbuild'

tasks:
	help: =>
		show "Commands:"
		for cmd in *({"help", "info", "build", "clean", "watch", "serve [--port <port>]"})
			show "\t#{cmd}"

	info: => moonbuild 'info'
	build: => moonbuild j: true
	clean: => moonbuild 'clean'

	watch: => watch {'src', 'data'}, {}, 'live', (-> true), -> cmd "moonbuild -jy"

	serve: => cmdfail "python3 -m http.server --directory out #{@port or 8080}"

