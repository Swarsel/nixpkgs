{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  numpy,
  pdfium-binaries,
  pillow,
  pkgsCross,
  pytestCheckHook,
  python,
  removeReferencesTo,
  setuptools-scm,
}:

let
  # They demand their own fork of ctypesgen
  ctypesgen = buildPythonPackage rec {
    pname = "ctypesgen";
    version = "1.1.1+g${src.rev}"; # the most recent tag + git version

    src = fetchFromGitHub {
      owner = "pypdfium2-team";
      repo = "ctypesgen";
      rev = "3961621c3e057015362db82471e07f3a57822b15";
      hash = "sha256-0OBY7/Zn12rG20jNYG65lANTRVRIFvE0SgUdYGFpRtU=";
    };

    build-system = [
      setuptools-scm
    ];

    pyproject = true;
  };

in
buildPythonPackage rec {
  pname = "pypdfium2";
  version = "5.7.0";

  src = fetchFromGitHub {
    owner = "pypdfium2-team";
    repo = "pypdfium2";
    tag = version;
    hash = "sha256-zc/83Ypmxul8fB3q0lUSgC9yfcdg7tJuZff+0LE0w30=";
  };

  nativeBuildInputs = [
    removeReferencesTo
  ];

  propagatedBuildInputs = [
    pdfium-binaries
  ];

  env = {
    CPP = "${stdenv.cc.targetPrefix}cpp";
    PDFIUM_BINARY = "${pdfium-binaries}/lib/libpdfium${stdenv.targetPlatform.extensions.sharedLibrary}";
    PDFIUM_HEADERS = "${pdfium-binaries}/include";
    PDFIUM_PLATFORM = "system-search:${pdfium-binaries.version}";
  };

  preBuild = ''
    getVersion() {
      cat ${pdfium-binaries}/VERSION | grep $1 | sed 's/.*=//'
    }
    export GIVEN_FULLVER="$(getVersion MAJOR).$(getVersion MINOR).$(getVersion BUILD).$(getVersion PATCH)"
  '';

  nativeCheckInputs = [
    numpy
    pillow
    pytestCheckHook
  ];

  # Remove references to stdenv in comments.
  postInstall = ''
    remove-references-to -t ${stdenv.cc.cc} $out/${python.sitePackages}/pypdfium2_raw/bindings.py
  '';

  build-system = [
    ctypesgen
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pypdfium2"
  ];

  passthru = {
    tests.cross = pkgsCross.aarch64-multiplatform.python3Packages.pypdfium2;

    updateScript = gitUpdater {
      allowedVersions = "^[.0-9]+$";
    };
  };

  meta = {
    description = "Python bindings to PDFium";
    homepage = "https://pypdfium2.readthedocs.io/";
    changelog = "https://github.com/pypdfium2-team/pypdfium2/releases/tag/${version}";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ booxter ];
  };
}
