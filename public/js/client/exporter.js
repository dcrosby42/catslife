(function() {
  var Exporter;

  Exporter = {};

  Exporter.isBrowser = function() {
    return typeof window !== 'undefined';
  };

  Exporter.isNode = function() {
    return (typeof module !== 'undefined') && (typeof module.exports !== 'undefined');
  };

  Exporter["export"] = function(name, obj) {
    if (Exporter.isBrowser()) {
      return window[name] = obj;
    } else if (Exporter.isNode()) {
      return module.exports = obj;
    }
  };

  Exporter["export"]("Exporter", Exporter);

}).call(this);
