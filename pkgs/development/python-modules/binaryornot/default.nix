{
  lib,
  buildPythonPackage,
  chardet,
  fetchPypi,
  hypothesis,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "binaryornot";
  version = "0.4.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NZUB38nUBjLtyfrIkOGVQtsaKHu8+lgXW2Zlg5IBgGE=";
  };

  nativeCheckInputs = [ hypothesis ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ chardet ];

  prePatch = ''
    # TypeError: binary() got an unexpected keyword argument 'average_size'
    substituteInPlace tests/test_check.py \
      --replace-fail "average_size=512" ""
  '';

  pyproject = true;
  pythonImportsCheck = [ "binaryornot" ];

  meta = {
    description = "Ultra-lightweight pure Python package to check if a file is binary or text";
    homepage = "https://github.com/audreyr/binaryornot";
    license = lib.licenses.bsd3;
  };
})
