{
  lib,
  buildPythonPackage,
  cython,
  fetchhg,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ruamel-yaml-clib";
  version = "0.2.15";

  src = fetchhg {
    url = "http://hg.code.sf.net/p/ruamel-yaml-clib/code";
    rev = version;
    hash = "sha256-SnMELcG2L2ei3UjImljjG1sSCHHROhXYcLe5kAR6h8E=";
  };

  # circular dependency with ruamel-yaml
  # pythonImportsCheck = [ "_ruamel_yaml" ];
  nativeBuildInputs = [ cython ];
  preBuild = "cython _ruamel_yaml.pyx -3 --module-name _ruamel_yaml -I.";
  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order";
    homepage = "https://sourceforge.net/projects/ruamel-yaml-clib/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
