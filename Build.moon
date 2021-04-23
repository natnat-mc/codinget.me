require 'moonscript'
lua_prefix = "./lua_modules/share/lua/#{_VERSION\sub -3}"
lua_cprefix = "./lua_modules/lib/lua/#{_VERSION\sub -3}"
package.path = "./?.lua;./?/init.lua;#{lua_prefix}/?.lua;#{lua_prefix}/?/init.lua"
package.cpath = "./?.so;#{lua_cprefix}/?.so"
package.moonpath = "./?.moon;./?/init.moon"

cjson = require 'cjson'

-- build tools
public var LESSC: './node_modules/.bin/lessc'
public var MINHTML: {'./node_modules/.bin/html-minifier', '--collapse-whitespace', '--remove-redundant-attributes'}
public var MINCSS: './node_modules/.bin/csso'
public var CONVERT: 'convert'

-- standard binaries
public var RM: {'rm', '-f'}
public var CP: 'cp'
public var MKDIR: {'mkdir', '-p'}

-- list the subtemplates we always use
var SUBTEMPLATES: _.wildcard "src/subtemplates/*.etlua"

-- list the pages we need to build
var PAGES: cjson.decode _.readfile 'data/pages.json'
var PAGE_MAP: {"out/#{page.html}.html", page for page in *PAGES}

-- public targets
with default public target 'all'
	\after "pages"
	\after "css"
	\after "assets"

with public target "info"
	\fn =>
		print "Pages:"
		for page in *PAGES
			print "\t'#{page.title}' (md: #{page.md} -> html: #{page.html}; template: #{page.template}; og: #{page.og})"

with public target "pages"
	\after ["page-#{page.html}" for page in *PAGES]

with public target "clean"
	\fn =>
		_.cmd RM, ["out/#{page.html}.html" for page in *PAGES]
		_.cmd RM, "out/styles.css"
		_.cmd RM, "out/avatar.png", "out/bg.png", "out/favicon.png", "out/favicon.ico"

with public target "css"
	\produces "out/styles.css"
	\depends "src/styles.less"
	\depends _.wildcard "src/*.less"
	\fn =>
		_.cmd LESSC, @infile, @outfile
		_.cmd MINCSS, @outfile, '-o', @outfile

with public target "assets"
	\after "out/avatar.png"
	\after "out/bg.png"
	\after "out/favicon.png", "out/favicon.ico"

-- actual targets
for page in *PAGES
	with target "page-#{page.html}"
		\produces "out/#{page.html}.html"
		\depends "data/#{page.md}.md"
		\depends "src/#{page.template}.etlua"
		\depends SUBTEMPLATES
		\depends "src/dopage.moon"
		\depends "data/og.json" if page.og
		\fn =>
			local page, cjson
			cjson = require 'cjson'
			page = PAGE_MAP[1][@outfile]
			import dopage from require 'src.dopage'
			_.writefile @outfile, dopage
				title: page.title
				md: _.readfile @infile
				template: _.readfile @infiles[2]
				og: page.og and cjson.decode _.readfile 'data/og.json'
				pages: PAGES
				:page
			_.cmd MINHTML, @outfile, '-o', @outfile

with target "out/avatar.png"
	\produces "%"
	\depends _.wildcard "data/avatar.*"
	\fn => _.cmd CONVERT, @infile, '-resize', '128x128', @outfile

with target "out/bg.png"
	\produces "%"
	\depends _.wildcard "data/bg.*"
	\fn => _.cmd CONVERT, @infile, '-resize', '1920x1080', @outfile

with target "out/favicon.png"
	\produces "%"
	\depends _.wildcard "data/avatar.*"
	\fn => _.cmd CONVERT, @infile, '-resize', '64x64', @outfile
with target "out/favicon.ico"
	\produces "%"
	\depends _.wildcard "data/avatar.*"
	\fn => _.cmd CONVERT, @infile, '-resize', '64x64', @outfile
