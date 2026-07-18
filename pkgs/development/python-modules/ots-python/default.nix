{
  lib,
  buildPythonPackage,
  fetchPypi,
  opentype-sanitizer,
  pytestCheckHook,
  replaceVars,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ots-python";
  version = "9.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-1Zdd+eRECimZl8L8CCkm7pCjN0TafSsc5i2Y6/oH88I=";
    pname = "opentype-sanitizer";
  };

  patches = [
    # Invoke ots-sanitize from the opentype-sanitizer package instead of
    # downloading precompiled binaries from the internet.
    # (nixpkgs-specific, not upstreamable)
    (replaceVars ./0001-use-packaged-ots.patch {
      ots_sanitize = "${opentype-sanitizer}/bin/ots-sanitize";
    })
  ];

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ opentype-sanitizer ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Python wrapper for ots (OpenType Sanitizer)";
    homepage = "https://github.com/googlefonts/ots-python";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
