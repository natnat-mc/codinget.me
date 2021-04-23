markdown = require 'markdown'
import render from require 'etlua'

mkmenu = (pages, page) ->
	[{text: p.title, url: "#{p.html}.html", current: p==page} for p in *pages]

subtemplate = (name, data) ->
	fd = assert io.open "src/subtemplates/#{name}.etlua", 'r'
	template = assert fd\read '*a'
	fd\close!
	render template, data

dopage = (data) ->
	import title, md, template, og, pages, page from data
	render template,
		:title
		body: markdown md
		:og
		menu: mkmenu pages, page
		:subtemplate

:dopage
