{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coreschema,
  django,
  itypes,
  pytestCheckHook,
  requests,
  setuptools_80,
  standard-cgi,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "coreapi";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "core-api";
    repo = "python-client";
    tag = version;
    hash = "sha256-nNUzQbBaT7woI3fmvPvIM0SVDnt4iC2rQ9bDgUeFzLA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];

  dependencies = [
    django
    coreschema
    itypes
    uritemplate
    requests
    standard-cgi
  ];

  pyproject = true;

  meta = {
    description = "Python client library for Core API";
    homepage = "https://github.com/core-api/python-client";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
