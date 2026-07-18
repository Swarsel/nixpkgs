{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  # propagates
  pyopenssl,
  # tests
  pytestCheckHook,
  requests,
  responses,
  six,
}:

buildPythonPackage rec {
  pname = "paypalhttp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "paypal";
    repo = "paypalhttp_python";
    tag = version;
    hash = "sha256-3ihcpYtpcejPkiyf4g4jveyNU6flQB2sv9EZ5Pd7tUc=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-K2hO3XRrJ+Gm+rLtWRPy0E2syLS4RhNNHIA3w4xVYtY=";
      # fix content-type header case sensitiyivy
      url = "https://github.com/paypal/paypalhttp_python/commit/72609783230663b8e34c6f0384837db7b166c8f4.patch";
    })
  ];

  postPatch = ''
    substituteInPlace tests/http_response_test.py \
      --replace-fail assertEquals assertEqual
  '';

  propagatedBuildInputs = [
    requests
    six
    pyopenssl
  ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  format = "setuptools";

  meta = {
    description = "PayPalHttp is a generic HTTP Client";
    homepage = "https://github.com/paypal/paypalhttp_python";
    changelog = "https://github.com/paypal/paypalhttp_python/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
