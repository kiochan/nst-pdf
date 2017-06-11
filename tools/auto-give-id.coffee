fs = require 'fs'

fp = ""
if process.argv[2]?
  fp = process.argv[2]
else
  fp = "./input.txt"

start = 0
if process.argv[3]?
  start = +process.argv[3]
  if !isNaN start
    start = ~~start
  else
    start = 0

prefix = ""
if process.argv[4]?
  prefix = process.argv[4]

data = (fs.readFileSync fp)
.toString()
.replace(/\r/g, "")
.split("\n")

i = 0
j = start
while data[i]?
  if data[i].match /^empty$/
    #str = "000000#{j}"
    #str = str.substring str.length-6, str.length
    #str = prefix + str
    str = prefix + j
    data[i] = str
    #console.log "found: give id >> #{str}"
    j++
  i++

fs.writeFileSync "#{fp}_.nst", data.join "\n"

process.exit(0)
