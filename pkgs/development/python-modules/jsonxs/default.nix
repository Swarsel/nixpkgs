{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:
let
  pname = "jsonxs";
  version = "0.6";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "fboender";
    repo = "jsonxs";
    rev = "v${version}";
    hash = "sha256-CmKK+qStb9xjmEACY41tQnffD4cMUUQPb74Cni5FTEk=";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python library that uses path expression strings to get and set values in JSON";
    homepage = "https://github.com/fboender/jsonxs";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.tie ];
  };
}
