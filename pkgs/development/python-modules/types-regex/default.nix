{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-regex";
  version = "2026.6.28.20260630";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-X6/kNLV409d2QKq5SKPr/J7+pyNBK/rlVRs/VQhqtqc=";
    pname = "types_regex";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "regex-stubs" ];

  meta = {
    description = "Typing stubs for regex";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dwoffinden ];
  };
})
