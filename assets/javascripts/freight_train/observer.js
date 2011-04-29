//
// Observer
//
// Adapted from an example on The Grubbsian
// http://www.thegrubbsian.com/
//
var Observer = (function(){
  var Observation = function(name, func) {
    this.name = name;
    this.func = func;
  };
  var constructor = function() {
    this.observations = [];
  };
  function select(array, fn) {
    var selected = [];
    for(var i=0, ii=array.length, item; i<ii; i++) {
      item = array[i];
      fn(item) && selected.push(item);
    }
    return selected;
  }
  constructor.prototype = {
    observe: function(name, func) {
      var exists = select(this.observations, function(i) {
        return (i.name==name) && (i.func==func);
      }).length > 0;
      !exists && this.observations.push(new Observation(name, func));
    },
    unobserve: function(name, func) {
      for(var i=0, ii=this.observations.length, observation; i<ii;) {
        observation = this.observations[i];
        if((observation.name==name) && (observation.func==func)) {
          this.observations.splice(i, 1);
        } else {
          i += 1;
        }
      }
    },
    fire: function(name, data, scope) {
      !(data instanceof Array) && (data = [data]);
      var _observations = select(this.observations, function(i) { return (i.name==name); });
      for(var i=0, ii=_observations.length; i<ii; i++) {
        _observations[i].func.apply(scope, data);
      }
    }
  };
  return constructor;
})();
