parseStancMessage = (msg) ->
  lines = msg.split("\n")

  if (i for line, i in lines when /^SYNTAX ERROR/.test(line)).length
    # Get line numbers for important lines in the
    lineSyntaxError = (i for line, i in lines when /^SYNTAX ERROR/.test(line))
    lineError = (i for line, i in lines when /^ERROR at line/.test(line))
    lineCol = (i for line, i in lines when /^\s*\^\s*$/.test(line))
    lineParserExp = (i for line, i in lines when /^PARSER EXPECTED/.test(line))

    # Description of the Error
    message = []
    descriptionLines = lines[(lineSyntaxError[0] + 2)...(lineError[0] - 1)]
    if descriptionLines.length
      message.push descriptionLines.join('\n')
    if lineParserExp.length
      message.push lines[lineParserExp[0]..].join('\n')
    # Line Number of the Error
    lineNum = Number /^ERROR at line ([0-9]+)/i.exec(lines[lineError[0]])[1]
    # Get column from location of ^
    # and subtracting the width of the line number before it
    prefix = lines[lineCol[0] - 1].indexOf(':')
    colNum = lines[lineCol[0]].indexOf('^') - prefix
    retObj = {type: 'Error',
              text: message.join('\n\n'),
              range: [[lineNum, colNum], [lineNum, colNum + 1]]}

  # Cases in which no syntax error, but a parser error
  # AFAIK this only happens if there is stuff after the model
  else if (i for line, i in lines when /PARSER EXPECTED: whitespace to end of file/.test(line)).length
    lineFoundAt = (i for line, i in lines when /^FOUND AT line/.test(line))[0]
    lineNum = /FOUND AT line ([0-9]+):/.exec(lines[lineFoundAt])[1]
    message = 'PARSER EXPECTED: whitespace to end of file'

    retObj = {type: 'Error',
              text: message,
              range: [[lineNum, colNum], [lineNum, colNum + 1]]}

  else
    retObj = null

  return retObj

module.exports =
  config:
    executablePath:
      type: 'string'
      default: 'stanc'
      description: 'Full path to binary (e.g. /usr/local/bin/stanc)'

  activate: ->
    require('atom-package-deps').install()

  provideLinter: ->
    helpers = require('atom-linter')
    path = require('path')

    provider =
      name: 'stanc'
      grammarScopes: ['source.stan']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) ->
        filePath = textEditor.getPath()
        fileText = textEditor.getText() + '\n'
        fileText += '\n' if fileText.slice(-1) isnt '\n'
        return helpers.tempFile path.basename(filePath), fileText, (tmpFilename) ->
          parameters = [tmpFilename]
          execPath = atom.config.get('linter-stanc.executablePath')
          return helpers.exec(execPath, parameters, {stream: 'stdout'}).then (result) ->
            toReturn = parseStancMessage(result)
            return toReturn
