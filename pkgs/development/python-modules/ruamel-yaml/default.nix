{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  ruamel-base,
  ruamel-yaml-clib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ruamel-yaml";
  version = "0.19.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-U+tmzSeEnv+Wjr+PC/YfRs2sLaHR81dt1MzumyXDGZM=";
    pname = "ruamel_yaml";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ ruamel-base ] ++ lib.optional (!isPyPy) ruamel-yaml-clib;
  # Tests use relative paths
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "ruamel.yaml" ];

  meta = {
    description = "YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order";
    homepage = "https://sourceforge.net/projects/ruamel-yaml/";
    changelog = "https://sourceforge.net/p/ruamel-yaml/code/ci/default/tree/CHANGES";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
