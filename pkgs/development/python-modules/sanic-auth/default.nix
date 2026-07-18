{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  sanic,
  sanic-testing,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sanic-auth";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-KAU066S70GO1hURQrW0n+L5/kFzpgen341hlia0ngjU=";
    pname = "Sanic-Auth";
  };

  postPatch = ''
    # Support for httpx>=0.20.0
    substituteInPlace tests/test_auth.py \
      --replace-fail "allow_redirects=False" "follow_redirects=False"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    sanic-testing
  ];

  build-system = [ setuptools ];
  dependencies = [ sanic ];

  disabledTests = [
    # incompatible with sanic>=22.3.0
    "test_login_required"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sanic_auth" ];

  meta = {
    description = "Simple Authentication for Sanic";
    homepage = "https://github.com/pyx/sanic-auth/";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
  };
}
