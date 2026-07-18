{
  lib,
  fetchFromGitHub,
  black,
  buildPythonPackage,
  # important downstream dependencies
  flit,
  flit-core,
  mypy,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "tomli";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "tomli";
    rev = version;
    hash = "sha256-PVYwCUGQSuCe5WMeOBJpGXiJ4keVllzg9H3y+Il+Nr8=";
  };

  nativeBuildInputs = [ flit-core ];
  nativeCheckInputs = [ unittestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "tomli" ];

  passthru.tests = {
    # test downstream dependencies
    inherit
      flit
      black
      mypy
      setuptools-scm
      ;
  };

  meta = {
    description = "Python library for parsing TOML, fully compatible with TOML v1.0.0";
    homepage = "https://github.com/hukkin/tomli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
