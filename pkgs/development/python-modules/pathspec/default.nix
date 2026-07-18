{
  lib,
  # for passthru.tests
  awsebcli,
  black,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  hatchling,
  unittestCheckHook,
  yamllint,
}:

buildPythonPackage rec {
  pname = "pathspec";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F9tezVJBBKEg4XOBTJA2epapjQfEWy4QwvORn/+Rv1o=";
  };

  nativeBuildInputs = [ flit-core ];
  checkInputs = [ unittestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pathspec" ];

  passthru.tests = {
    inherit
      awsebcli
      black
      hatchling
      yamllint
      ;
  };

  meta = {
    description = "Utility library for gitignore-style pattern matching of file paths";
    homepage = "https://github.com/cpburnz/python-path-specification";
    changelog = "https://github.com/cpburnz/python-pathspec/blob/v${version}/CHANGES.rst";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}
