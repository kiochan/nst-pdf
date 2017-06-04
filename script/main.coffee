version = "v0.1.0"

fs = require "fs"
md5 = require "md5"
url = require 'url'
path = require 'path'
{app, BrowserWindow, ipcMain} = require "electron"
ipc = ipcMain
parser = require "./parser.coffee"
showdown  = new (require('showdown').Converter)
pdf = require('html-pdf')
css = require './css.coffee'


# init
showdown
.setOption "tables", true

win = null
createWindow = () ->
  win = new BrowserWindow
    useContentSize: yes
    width: 300
    height: 400
    minWidth: 300
    minHeight: 400
    maxWidth: 300
    maxHeight: 400
    zoomFactor: 1
    fullscreen: no
    fullscreenable: no
    hasShadow: yes # macOS
    icon: null

  win.setMenu null

  win.loadURL url.format
    pathname: path.join __dirname, "../html/renderer.html"
    protocol: 'file:'
    slashes: true

  win.once "ready-to-show", ->
    win.show()

  win.on 'closed', () ->
    win = null

app.on 'ready', createWindow

app.on 'window-all-closed', () ->
  # if process.platform != 'darwin'
  do app.quit

###
app.on 'activate', () ->
  if win == null
    do createWindow
###

ipc.on "input-data", (event, input) ->
  event.sender.send "ipc-log", "尝试读取：#{input}"
  if !(input.match /(\.txt$)|(\.nst$)/)
    event.sender.send "ipc-log", "非法文件！只接受纯文本文档(.txt .nst)"
    return

  fs.stat input, (err, stats) ->
    if err? || !stats.isFile
      event.sender.send "ipc-log", "非法文件！不支持文件夹。"
      return
    if stats.size > 2 * 1024 * 1024
      event.sender.send "ipc-log", "文件过大！"
      return

    fs.readFile input, (err, data) ->
      event.sender.send "ipc-log", "读取成功！"

      if yes &&
      data[0].toString(16).toLowerCase() == "ef" && data[1].toString(16).toLowerCase() == "bb" && data[2].toString(16).toLowerCase() == "bf"
        event.sender.send "ipc-log", "发现BOM"
        data = data.slice(3);
      title = path.basename(input)
      parser title, data.toString(), (md, err_msg) ->
        event.sender.send "ipc-log", "正在转换！"
        output = "#{input}.pdf"
        html = showdown.makeHtml md
        html = """
        <!doctype html>
        <html>
        <head>
        <title>#{title}</title>
        <meta charset="utf-8">
        <style>
        #{css}
        </style>
        </head>
        <body>
        #{html}
        </body>
        </html>
        """
        fs.writeFile "#{input}.html", html

        pdf
        .create html,
          format: "A4"
          border: "0.5in"
          tables: yes
        .toFile output, (err, res) ->
          if err
            event.sender.send "ipc-log", "输出文件发生错误！"
            return
          event.sender.send "ipc-log", "转换成功！"
          event.sender.send "ipc-log", "输出到：#{output}"

  return
