{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-httpserver,
  pytestCheckHook,
  python-slugify,
  python-status,
}:

buildPythonPackage rec {
  pname = "simple-rest-client";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "allisson";
    repo = "python-simple-rest-client";
    rev = version;
    hash = "sha256-IaLo7nBMIabi4ZjZ4ZLJliCL/dzidaCBCmn0cq7Fzdw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pytest-runner" ""
    substituteInPlace requirements-dev.txt \
      --replace "asyncmock" ""
  '';

  propagatedBuildInputs = [
    httpx
    python-slugify
    python-status
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-httpserver
    pytestCheckHook
  ];

  disabledTestPaths = [ "tests/test_decorators.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "simple_rest_client" ];

  meta = {
    description = "Simple REST client for Python";
    homepage = "https://github.com/allisson/python-simple-rest-client";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
