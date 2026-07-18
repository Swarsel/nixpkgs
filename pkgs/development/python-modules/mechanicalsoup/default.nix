{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  lxml,
  pytest-cov-stub,
  pytest-httpbin,
  pytest-mock,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mechanicalsoup";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "MechanicalSoup";
    repo = "MechanicalSoup";
    tag = "v${version}";
    hash = "sha256-fu3DGTsLrw+MHZCFF4WHMpyjqkexH/c8j9ko9ZAeAwU=";
  };

  postPatch = ''
    # Is in setup_requires but not used in setup.py
    substituteInPlace setup.py \
      --replace "'pytest-runner'" ""
    substituteInPlace setup.cfg \
      --replace " --flake8" ""
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-httpbin
    pytest-mock
    pytestCheckHook
    requests-mock
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    lxml
    requests
  ];

  disabledTests = [
    # Missing module
    "test_select_form_associated_elements"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mechanicalsoup" ];

  meta = {
    description = "Python library for automating interaction with websites";
    homepage = "https://github.com/hickford/MechanicalSoup";
    changelog = "https://github.com/MechanicalSoup/MechanicalSoup/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jgillich
      fab
    ];
  };
}
