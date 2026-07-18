{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  fetchpatch,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "openevsewifi";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "miniconfig";
    repo = "python-openevse-wifi";
    rev = "v${version}";
    hash = "sha256-7+BC5WG0JoyHNjgsoJBQRVDpmdXMJCV4bMf6pIaS5qo=";
  };

  patches = [
    # Switch to poetry-core, https://github.com/miniconfig/python-openevse-wifi/pull/31
    (fetchpatch {
      hash = "sha256-XGeyi/PchBju1ICgL/ZCDGCbWwIJmLAcHuKaj+kDsI0=";
      name = "switch-to-poetry-core.patch";
      url = "https://github.com/miniconfig/python-openevse-wifi/commit/1083868dd9f39a8ad7bb17f02cea1b8458e5b82d.patch";
    })
  ];

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    deprecated
    requests
  ];

  nativeCheckInputs = [
    requests-mock
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "openevsewifi" ];

  meta = {
    description = "Module for communicating with the wifi module from OpenEVSE";
    homepage = "https://github.com/miniconfig/python-openevse-wifi";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
