version = "v0.1.0"

fs = require "fs"
md5 = require "md5"
url = require 'url'
path = require 'path'
markdownpdf = require "markdown-pdf"
{app, BrowserWindow, ipcMain} = require "electron"
ipc = ipcMain
parser = require "./parser.coffee"

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
  if process.platform != 'darwin'
    do app.quit

app.on 'activate', () ->
  if win == null
    do createWindow

ipc.on "input-data", (event, input) ->
  event.sender.send "ipc-log", "正在尝试读取：#{input}"
  if (String input).match /\.txt$|\.nst$/
    try
      fs.stat input, (err, stats) ->
        if err? || !stats.isFile
          event.sender.send "ipc-log", "读取成功！正在转换中。"
        if stats.size > 2 * 1024 * 1024
          event.sender.send "ipc-log", "文件过大！"

      fs.readFile input, (err, data) ->
        event.sender.send "ipc-log", "读取成功！正在转换中。"

        if yes &&
        data[0].toString(16).toLowerCase() == "ef" && data[1].toString(16).toLowerCase() == "bb" && data[2].toString(16).toLowerCase() == "bf"
          event.sender.send "发现BOM"
          data = data.slice(3);
        parser path.basename(input), data.toString(), (data, err_msg) ->
          if err_msg
            event.sender.send "ipc-log", "输出失败！请关闭已打开的 PDF 文件。"
            return
          tmp_path = "#{input}._$$#{md5(input)}"
          fs.writeFile tmp_path, data, (err) ->
            event.sender.send "ipc-log", "创建临时文件： #{tmp_path}"
            try
              cwdp = process.cwd()
              if !cwdp.match /^\//
                cwdp = "file:///" + cwdp.replace /\\/g, "/"
                cwdp += "/style/github-markdown.css"
              console.log cwdp
              markdownpdf
                cssPath: cwdp
                paperFormat: "A4"
              .from tmp_path
              .to "#{input}.pdf", ->
                event.sender.send "ipc-log", "输出到： #{input}.pdf"
                fs.unlink tmp_path, ->
                  event.sender.send "ipc-log", "完成！\n"
                  return
                return
            catch error
              event.sender.send "ipc-log", "输出失败！请关闭已打开的 PDF 文件。"
    catch error
      event.sender.send "ipc-log", "读取失败！"
  else
    event.sender.send "ipc-log", "文件类型错误！"
  return
