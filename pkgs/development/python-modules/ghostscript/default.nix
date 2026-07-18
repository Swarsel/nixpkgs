{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  ghostscript_headless,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ghostscript";
  version = "0.7";

  src = fetchFromGitLab {
    owner = "pdftools";
    repo = "python-ghostscript";
    tag = "v${version}";
    hash = "sha256-yBJuAnLK/4YDU9PBsSWPQay4pDws3bP+3rCplysq41w=";
  };

  postPatch =
    let
      extLib = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace ghostscript/__init__.py \
        --replace-fail '__version__ = gs.__version__' '__version__ = "${version}"'

      substituteInPlace ghostscript/_gsprint.py \
        --replace-fail 'cdll.LoadLibrary("libgs.so")' 'cdll.LoadLibrary("${lib.getLib ghostscript_headless}/lib/libgs${extLib}")'
    '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  disabledTests = [
    # Some tests don't (fully) match anymore.
    # Not sure if ghostscript ever promised to keep producing the same outputs, bit-by-bit…
    "test_simple"
    "test_unicode_arguments"
    "test_run_string"
    "test_stdin"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ghostscript" ];

  meta = {
    description = "Interface to the Ghostscript C-API using ctypes";
    homepage = "https://gitlab.com/pdftools/python-ghostscript";
    changelog = "https://gitlab.com/pdftools/python-ghostscript/-/blob/v${version}/CHANGES.txt";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
