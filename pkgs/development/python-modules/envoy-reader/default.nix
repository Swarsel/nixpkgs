{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  envoy-utils,
  httpx,
  pyjwt,
  pytest-asyncio,
  pytest-raises,
  pytestCheckHook,
  respx,
  setuptools,
}:

buildPythonPackage rec {
  pname = "envoy-reader";
  version = "0.21.3";

  src = fetchFromGitHub {
    owner = "jesserizzo";
    repo = "envoy_reader";
    rev = version;
    hash = "sha256-aIpZ4ln4L57HwK8H0FqsyNnXosnAp3ingrJI6/MPS90=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner>=5.2" ""
  '';

  nativeCheckInputs = [
    pytest-raises
    pytest-asyncio
    pytestCheckHook
    respx
  ];

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    envoy-utils
    httpx
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "envoy_reader" ];
  pythonRelaxDeps = [ "pyjwt" ];

  meta = {
    description = "Python module to read from Enphase Envoy units";
    homepage = "https://github.com/jesserizzo/envoy_reader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
