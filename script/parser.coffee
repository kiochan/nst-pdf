# parser.coffee

module.exports = (name, data_as_string, callback) ->

  do ->

    _data = data_as_string.replace /\r\n/g, "\n"

    # split data as array
    arr = [String _data]
    data = arr.concat (_data.split "\n")

    output_data = "# #{name} 剧本\n\nThank 声优大大们 with <3\n\n"

    ct = {}

    # empty head of table
    output_data_tabel = "| cmd | id | opt | content |\n| :--- | :--- | :--- | :--- |\n"

    l = 1

    lp = ->
      line = data[l]

      if line.match /^#.*/
        output_data_tabel += "|注释|||#{data[l].replace /^#/, ""}|\n"
        l += 1

      else if line.match /^@cg/i
        d = data[l+1]
        if !ct["CG"]? then ct["CG"] = []
        if !ct["CG"][d]?
          ct["CG"][d] = 1
        else
          ct["CG"][d]++
        output_data_tabel += "|CG|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@sfx/i
        d = data[l+1]
        if !ct["音效"]? then ct["音效"] = []
        if !ct["音效"][d]?
          ct["音效"][d] = 1
        else
          ct["音效"][d]++
        output_data_tabel += "|音效|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@time/i
        d = data[l+1]
        output_data_tabel += "|时间|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@goto/i
        d = data[l+1]
        output_data_tabel += "|跳转|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@atmos/i
        d = data[l+1]
        if d != "null"
          if !ct["环境音"]? then ct["环境音"] = []
          if !ct["环境音"][d]?
            ct["环境音"][d] = 1
          else
            ct["环境音"][d]++
          output_data_tabel += "|环境音|||\[#{d}\]|\n"
        else
          output_data_tabel += "|音乐|||停止播放|\n"
        l += 2

      else if line.match /^@bgm/i
        d = data[l+1]
        if d != "null"
          if !ct["音乐"]? then ct["音乐"] = []
          if !ct["音乐"][d]?
            ct["音乐"][d] = 1
          else
            ct["音乐"][d]++
          output_data_tabel += "|音乐|||\[#{d}\]|\n"
        else
          output_data_tabel += "|音乐|||停止播放|\n"
        l += 2

      else if line.match /^@tag/i
        d = data[l+1]
        output_data_tabel += "|标签|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@bg/i
        d = data[l+1]
        if !ct["背景"]? then ct["背景"] = []
        if !ct["背景"][d]?
          ct["背景"][d] = 1
        else
          ct["背景"][d]++
        output_data_tabel += "|背景|||\[#{d}\]|\n"
        l += 2

      else if line.match /^@value/i
        name = data[l+1]
        option = data[l+1]
        new_value = data[l+1]
        output_data_tabel += "|数值|#{name}|#{option}|\[#{new_value}\]|\n"
        l += 4

      else if line.match /^[0-9a-z]+$/i
        # 剧本
        id = data[l]
        l += 1
        name = data[l]
        if !name? || name.length == 0
          name = "[EMPTY]"
          output_data += "`empty name at line [#{l}]`\n\n"
        else
          l += 1
          text = ""
          if data[l].length == 0
            l += 1
            output_data += "`bad dialog at line [#{l}]`\n\n"
          else
            while data[l] != ""
              text += data[l]
              l += 1

            if !ct["角色（按照字数）"]? then ct["角色（按照字数）"] = []
            if !ct["角色（按照字数）"][name]?
              ct["角色（按照字数）"][name] = text.length
            else
              ct["角色（按照字数）"][name] += text.length

            if !ct["角色（按照句子）"]? then ct["角色（按照句子）"] = []
            if !ct["角色（按照句子）"][name]?
              ct["角色（按照句子）"][name] = 1
            else
              ct["角色（按照句子）"][name] += 1

            output_data_tabel += "|台词|`#{id}`|**#{name}**|**#{text}**|\n"

      else
        if !line.match /^ *$/
          output_data_tabel += "|unknow|||*#{line}*|\n"
          output_data += "`unknow script at line [#{l}]`\n\n"
        l += 1

      if l < data.length then setTimeout lp, 0
      else
        output_data += "\n"
        output_data += "## 需求资源\n"
        for key, cmd of ct
          output_data += "* #{key}\n"
          for k, c of cmd
            output_data += "    * #{k}: #{c}\n"
          output_data += "\n"
        output_data += "\n"
        output_data += "## 台本\n"
        output_data += output_data_tabel
        callback output_data

    do lp

  return
