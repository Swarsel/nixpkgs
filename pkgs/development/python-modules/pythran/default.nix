{
  lib,
  fetchFromGitHub,
  beniget,
  buildPythonPackage,
  gast,
  numpy,
  # native dependencies
  openmp,
  # dependencies
  ply,
  python,
  replaceVars,
  # build-system
  setuptools,
  xsimd,
}:

let
  inherit (python) stdenv;
in
buildPythonPackage rec {
  pname = "pythran";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "pythran";
    tag = version;
    hash = "sha256-H13FGApWCgBLWOtoZ5yEIV4Z+KAOK3Xs4KFM4oLmKmk=";
  };

  patches = [
    # Hardcode path to mp library
    (replaceVars ./0001-hardcode-path-to-libgomp.patch {
      gomp = "${
        if stdenv.cc.isClang then openmp else (lib.getLib stdenv.cc.cc)
      }/lib/libgomp${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  # xsimd: unvendor this header-only C++ lib
  postPatch = ''
    rm -r pythran/xsimd
    ln -s '${lib.getDev xsimd}'/include/xsimd pythran/
  '';

  # Test suite is huge and has a circular dependency on scipy.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ply
    gast
    numpy
    beniget
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pythran"
    "pythran.backend"
    "pythran.middlend"
    "pythran.passmanager"
    "pythran.toolchain"
    "pythran.spec"
  ];

  pythonRelaxDeps = [
    "gast"
    "beniget"
  ];

  meta = {
    description = "Ahead of Time compiler for numeric kernels";
    homepage = "https://github.com/serge-sans-paille/pythran";
    changelog = "https://github.com/serge-sans-paille/pythran/blob/${src.tag}/Changelog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
