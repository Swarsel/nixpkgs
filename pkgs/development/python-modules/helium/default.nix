{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  firefox,
  geckodriver,
  psutil,
  pytestCheckHook,
  selenium,
  setuptools,
  which,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "helium";
  version = "7.0.3";

  src = fetchFromGitHub {
    owner = "mherrmann";
    repo = "helium";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I3qLp3v6aIwGIelzNE5gRnvp/eHVPfzJijUxlT28Wqs=";
  };

  # helium doesn't support testing on all platforms
  doCheck = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64);

  nativeCheckInputs = [
    firefox
    geckodriver
    psutil
    pytestCheckHook
    which
    writableTmpDirAsHomeHook
  ];

  # Selenium setup
  preCheck = ''
    export TEST_BROWSER=firefox
    export SE_OFFLINE=true
  '';

  build-system = [ setuptools ];
  dependencies = [ selenium ];

  disabledTestPaths = [
    # All of the tests here fail, maybe because we force a driver to be found via envvars?
    "tests/api/test_no_driver.py"

    # New tests, not sure why they fail. Maybe due to forced firefox?
    "tests/api/test_write.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "helium" ];

  meta = {
    description = "Lighter web automation with Python";
    homepage = "https://github.com/mherrmann/helium";
    changelog = "https://github.com/mherrmann/helium/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    teams = with lib.teams; [ ngi ];
  };
})
