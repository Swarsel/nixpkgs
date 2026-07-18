{
  lib,
  fetchFromGitHub,
  authlib,
  buildPythonPackage,
  httpx,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysenz";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "nordicopen";
    repo = "pysenz";
    tag = "v${version}";
    hash = "sha256-gS9dsGQ8waOlUbHWHiJbQrvh4RdFb4SNEH4J4TbT2x8=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    authlib
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysenz" ];

  meta = {
    description = "Async Typed Python package for the Chemelex (nVent) RAYCHEM SENZ RestAPI";
    homepage = "https://github.com/nordicopen/pysenz";
    changelog = "https://github.com/nordicopen/pysenz/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
