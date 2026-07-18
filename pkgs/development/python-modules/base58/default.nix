{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyhamcrest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "base58";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xdDLP1tugejjXaV1Q4jdzG0NFLbGoTLLk9ae1YCnJ4w=";
  };

  nativeCheckInputs = [
    pyhamcrest
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    # avoid dependency on pytest-benchmark
    "test_decode_random"
    "test_encode_random"
  ];

  pyproject = true;
  pythonImportsCheck = [ "base58" ];

  meta = {
    description = "Base58 and Base58Check implementation";
    homepage = "https://github.com/keis/base58";
    changelog = "https://github.com/keis/base58/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
    mainProgram = "base58";
  };
}
