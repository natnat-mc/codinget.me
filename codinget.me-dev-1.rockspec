package = "codinget.me"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {}
}
dependencies = {
   "lua >= 5.1",
   "markdown >= 0.33-1",
   "etlua >= 1.3.0-1",
   "lua-cjson == 2.1.0-1"
}
