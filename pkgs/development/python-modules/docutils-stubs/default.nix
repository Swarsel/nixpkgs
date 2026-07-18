{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  docutils,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "docutils-stubs";
  version = "0.0.22";

  src = fetchFromGitHub {
    owner = "tk0miya";
    repo = "docutils-stubs";
    tag = finalAttrs.version;
    hash = "sha256-ng/f5e8ElFGNqtpdiQsv897TNkJ4gd++HAxON2l+80s=";
  };

  # Module doesn't have tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    docutils
  ];

  pyproject = true;

  meta = {
    description = "PEP 561 based Type information for docutils";
    homepage = "https://github.com/tk0miya/docutils-stubs";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
