# materialized doesn't use npm to pull in its few node dependencies but instead
# manually pulls the tar archives for each package and pulls out a couple of
# files.
#
# The list of modules can be found in this file
# https://github.com/MaterializeInc/materialize/blob/master/src/npm/lib.rs
[
  {
    version = "0.3.14";

    extra_file = {
      src = "dist/graphvizlib.wasm";
      dst = "js/vendor/@hpcc-js/graphvizlib.wasm";
    };

    hash = "sha256-EsbuFk9qtlm9yWpG29RnqVAHrP0rk3xyibQLy8qgRT4=";
    js_dev_file = "dist/index.js";
    js_prod_file = "dist/index.min.js";
    name = "@hpcc-js/wasm";
  }
  {
    version = "7.23.3";
    hash = "sha256-yxhB4OVOdV8hYNPqcap+5/JXYeaVrNGOSOG8lKpiG9E=";
    js_dev_file = "babel.js";
    js_prod_file = "babel.min.js";
    name = "@babel/standalone";
  }
  {
    version = "5.16.0";
    hash = "sha256-aQQRhnJxV5/9C+cQslctP3v/AePGfbSw8L3chObJzK4=";
    js_dev_file = "dist/d3.js";
    js_prod_file = "dist/d3.min.js";
    name = "d3";
  }
  {
    version = "3.1.1";
    css_file = "dist/d3-flamegraph.css";
    hash = "sha256-Ls3MqALr6+/A+n8jqFw7frIB++6d1W3lAXKU0qFZ2ok=";
    js_dev_file = "dist/d3-flamegraph.js";
    js_prod_file = "dist/d3-flamegraph.min.js";
    name = "d3-flame-graph";
  }
  {
    version = "1.0.11";
    hash = "sha256-St7nKpcYlJQl8qMmPkEHwmTufOHAeZK4lBZHo8VRXLA=";
    js_dev_file = "dist/pako.js";
    js_prod_file = "dist/pako.min.js";
    name = "pako";
  }
  {
    version = "16.14.0";
    hash = "sha256-X/8Bc4XvC8IqQWbW/PCRJQpmOBI/0AZT/hSFBf/uJU8=";
    js_dev_file = "umd/react.development.js";
    js_prod_file = "umd/react.production.min.js";
    name = "react";
  }
  {
    version = "16.14.0";
    hash = "sha256-2mYm9dwBFrWws6CB5bL6ghROTzX84RLM31hdnEbhG10=";
    js_dev_file = "umd/react-dom.development.js";
    js_prod_file = "umd/react-dom.production.min.js";
    name = "react-dom";
  }
]
