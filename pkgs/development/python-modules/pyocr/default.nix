{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  cuneiform,
  isPy3k,
  pillow,
  pytestCheckHook,
  replaceVars,
  setuptools,
  setuptools-scm,
  tesseract,
  withCuneiformSupport ? false,
  withTesseractSupport ? true,
}:

buildPythonPackage rec {
  pname = "pyocr";
  version = "0.8.5";

  # Don't fetch from PYPI because it doesn't contain tests.
  src = fetchFromGitLab {
    owner = "OpenPaperwork";
    repo = "pyocr";
    rev = version;
    hash = "sha256-gE0+qbHCwpDdxXFY+4rjVU2FbUSfSVrvrVMcWUk+9FU=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  patches =
    [ ]
    ++ (lib.optional withTesseractSupport (
      replaceVars ./paths-tesseract.patch {
        inherit tesseract;
        tesseractLibraryLocation = "${tesseract}/lib/libtesseract${stdenv.hostPlatform.extensions.sharedLibrary}";
      }
    ))
    ++ (lib.optional withCuneiformSupport (
      replaceVars ./paths-cuneiform.patch {
        inherit cuneiform;
      }
    ));

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ pillow ];
  nativeCheckInputs = [ pytestCheckHook ];
  disabled = !isPy3k;
  pyproject = true;

  meta = {
    inherit (src.meta) homepage;
    description = "Python wrapper for Tesseract and Cuneiform";
    changelog = "https://gitlab.gnome.org/World/OpenPaperwork/pyocr/-/blob/${version}/ChangeLog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      symphorien
      tomodachi94
    ];
  };
}
