{
  lib,
  # tests
  aiounittest,
  buildPythonPackage,
  fetchPypi,
  mock,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  # build-system
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "ddt";
  version = "1.7.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0hXWsIOWMBPEoZseTc1qlugOQ6t3UZWXpqz88umj4Es=";
  };

  nativeBuildInputs = [ setuptools ];
  # aiounittest is not compatible with Python 3.12.
  doCheck = pythonOlder "3.12";

  nativeCheckInputs = [
    aiounittest
    mock
    pytestCheckHook
    pyyaml
    six
  ];

  pyproject = true;

  meta = {
    description = "Data-Driven/Decorated Tests, a library to multiply test cases";
    homepage = "https://github.com/txels/ddt";
    changelog = "https://github.com/datadriventests/ddt/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
