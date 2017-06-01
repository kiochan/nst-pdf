# parser.coffee

module.exports = (data_as_string, callback) ->

  _data = data_as_string.replace /\r\n/g, "\n"

  # split data as array
  arr = [String _data]
  data = arr.concat (_data.split "\n")

  # empty head of table
  output_data = "__cmd__|__id__|__opt__|__content__\n:-:|:-:|:-:|:-\n"

  l = 1

  lp = ->
    line = data[l]

    if line.match /^#/
      output_data += "注释|||#{data[l].replace /^#/, ""}\n"
      l += 1

    else if line.match /^@cg/i
      d = data[l+1]
      output_data += "CG|||\[#{d}\]\n"
      l += 2

    else if line.match /^@sfx/i
      d = data[l+1]
      output_data += "音效|||\[#{d}\]\n"
      l += 2

    else if line.match /^@bgm/i
      d = data[l+1]
      output_data += "音乐|||\[#{d}\]\n"
      l += 2

    else if line.match /^@bg/i
      d = data[l+1]
      output_data += "背景|||\[#{d}\]\n"
      l += 2

    else if line.match /^[0-9a-z]+$/i
      # 剧本
      id = data[l]
      l += 1
      name = data[l]
      l += 1
      text = ""
      while data[l] != ""
        text += data[l]
        l += 1
      output_data += "台词|`#{id}`|**#{name}**|**#{text}**\n"

    else
      if !line.match /^ *$/
        output_data += "说明|||*#{line}*\n"
      l += 1

    if l < data.length then setTimeout lp, 0 else callback(output_data)

  do lp

  return
