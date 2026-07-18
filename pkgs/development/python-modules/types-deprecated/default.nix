{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-deprecated";
  version = "1.3.1.20260520";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-TQ2eVSFDLZzogWn7i3k7RdcNjozBp+zVpEZau/g8mrQ=";
    pname = "types_deprecated";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=82.0.1" "setuptools" \
      --replace-fail "'deprecated-stubs' =" "'*' ="
  '';

  # Modules has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "deprecated-stubs" ];

  meta = {
    description = "Typing stubs for Deprecated";
    homepage = "https://pypi.org/project/types-Deprecated/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
