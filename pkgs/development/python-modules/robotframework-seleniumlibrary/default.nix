{
  lib,
  fetchFromGitHub,
  approvaltests,
  buildPythonPackage,
  click,
  pytest-mockito,
  pytestCheckHook,
  robotframework,
  robotframework-pythonlibcore,
  robotstatuschecker,
  selenium,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "robotframework-seleniumlibrary";
  version = "6.9.0";

  # no tests included in PyPI tarball
  src = fetchFromGitHub {
    owner = "robotframework";
    repo = "SeleniumLibrary";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NiB1dJWivyDc1ucldQ2cs3jTWt3hHY6AGsboKPmY+mo=";
  };

  nativeCheckInputs = [
    approvaltests
    pytest-mockito
    pytestCheckHook
    robotstatuschecker
  ];

  preCheck = ''
    mkdir utest/output_dir
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    robotframework
    robotframework-pythonlibcore
    selenium
  ];

  pyproject = true;

  meta = {
    description = "Web testing library for Robot Framework";
    homepage = "https://github.com/robotframework/SeleniumLibrary";
    changelog = "https://github.com/robotframework/SeleniumLibrary/blob/${finalAttrs.src.tag}/docs/SeleniumLibrary-${finalAttrs.version}.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
