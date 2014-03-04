Exporter = {}
Exporter.isBrowser = -> typeof window != 'undefined'
Exporter.isNode = -> (typeof module != 'undefined') and (typeof module.exports != 'undefined')

Exporter.export = (name,obj) ->
  if Exporter.isBrowser()
    window[name] = obj
  else if Exporter.isNode()
    module.exports = obj

Exporter.export "Exporter", Exporter
