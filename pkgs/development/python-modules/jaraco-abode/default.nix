{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  bx-py-utils,
  colorlog,
  importlib-resources,
  jaraco-classes,
  jaraco-collections,
  jaraco-context,
  jaraco-functools,
  jaraco-itertools,
  jaraco-net,
  keyring,
  lomond,
  more-itertools,
  platformdirs,
  pytest-responses,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-abode";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.abode";
    tag = "v${version}";
    hash = "sha256-nnnVtNXQ7Sa4wXl0ay3OyjvOq2j90pTwhK24WR8mrBo=";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-responses
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TEMP
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    requests
    lomond
    colorlog
    keyring
    requests-toolbelt
    jaraco-collections
    jaraco-context
    jaraco-classes
    jaraco-net
    more-itertools
    importlib-resources
    bx-py-utils
    platformdirs
    jaraco-itertools
    jaraco-functools
  ];

  disabledTests = [
    "_cookie_string"
    "test_cookies"
    "test_empty_cookies"
    "test_invalid_cookies"
    # Issue with the regex
    "test_camera_capture_no_control_URLs"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.abode" ];

  meta = {
    description = "Library interfacing to the Abode home security system";
    homepage = "https://github.com/jaraco/jaraco.abode";
    changelog = "https://github.com/jaraco/jaraco.abode/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jamiemagee
      dotlambda
    ];
  };
}
