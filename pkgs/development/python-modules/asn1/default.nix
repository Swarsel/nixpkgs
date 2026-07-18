{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asn1";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "andrivet";
    repo = "python-asn1";
    tag = "v${version}";
    hash = "sha256-gqFW+akhWwvtqJQb4LqcgjyJb6bcInl0gT6f2CMTtA0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests/test_asn1.py" ];
  pyproject = true;
  pythonImportsCheck = [ "asn1" ];
  pythonRemoveDeps = [ "enum-compat" ];

  meta = {
    description = "Python ASN.1 encoder and decoder";
    homepage = "https://github.com/andrivet/python-asn1";
    changelog = "https://github.com/andrivet/python-asn1/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
