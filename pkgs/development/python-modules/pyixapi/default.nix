{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pyjwt,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "pyixapi";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "peering-manager";
    repo = "pyixapi";
    tag = version;
    hash = "sha256-pKIm9YCWf5HCwJ76NLm6AmcJWGVErZu9dwl23p8maXs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    requests
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyixapi" ];
  pythonRelaxDeps = [ "pyjwt" ];

  meta = {
    description = "Python API client library for IX-API";
    homepage = "https://github.com/peering-manager/pyixapi/";
    changelog = "https://github.com/peering-manager/pyixapi/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
