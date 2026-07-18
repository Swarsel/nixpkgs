{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  lazy,
  # tests
  packaging-legacy,
  pytestCheckHook,
  requests,
  # build-system
  setuptools,
  tomli,
}:

buildPythonPackage (finalAttrs: {
  pname = "devpi-common";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "devpi";
    repo = "devpi";
    tag = "common-${finalAttrs.version}";
    hash = "sha256-YFY2iLnORzFxnfGYU2kCpJL8CZi+lALIkL1bRpfd4NE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools_changelog_shortener",' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    packaging-legacy
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    lazy
    requests
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "devpi_common" ];
  sourceRoot = "${finalAttrs.src.name}/common";

  meta = {
    description = "Utilities jointly used by devpi-server and devpi-client";
    homepage = "https://github.com/devpi/devpi";
    changelog = "https://github.com/devpi/devpi/blob/common-${finalAttrs.version}/common/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      confus
      lewo
      makefu
    ];
  };
})
