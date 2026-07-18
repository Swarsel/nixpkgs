{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyasn1";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "pyasn1";
    repo = "pyasn1";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fHpAJ1WSoLwaWuSMcfHjZmnl8oNhADrdjHaYIEmqQiw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyasn1" ];

  meta = {
    description = "Generic ASN.1 library for Python";
    homepage = "https://pyasn1.readthedocs.io";
    changelog = "https://github.com/pyasn1/pyasn1/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
