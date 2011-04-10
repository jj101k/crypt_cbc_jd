require "rbconfig.rb"
include Config
require "fileutils"
include FileUtils::Verbose

mkdir_p(CONFIG["sitelibdir"]+"/crypt")
install("cbc.rb", CONFIG["sitelibdir"]+"/crypt", :mode=>0644)
