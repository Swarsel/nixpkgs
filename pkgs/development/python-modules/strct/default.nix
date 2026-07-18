{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools_80,
  sortedcontainers,
}:

buildPythonPackage rec {
  pname = "strct";
  version = "0.0.35";

  src = fetchFromGitHub {
    owner = "shaypal5";
    repo = "strct";
    tag = "v${version}";
    hash = "sha256-4IykGzy1PTrRAbx/sdtzL4My4cDSlplL9rOFBcLbaB8=";
  };

  nativeBuildInputs = [ setuptools_80 ];
  # don't append .dev0 to version
  env.RELEASING_PROCESS = "1";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    sortedcontainers
  ];

  pyproject = true;

  pythonImportsCheck = [
    "strct"
    "strct.dicts"
    "strct.hash"
    "strct.lists"
    "strct.sets"
    "strct.sortedlists"
  ];

  meta = {
    description = "Small pure-python package for data structure related utility functions";
    homepage = "https://github.com/shaypal5/strct";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
