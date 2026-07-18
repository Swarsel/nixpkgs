{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  igraph,
  ninja,
  pybind11,
  pygments,
  pytestCheckHook,
  scikit-build-core,
  setuptools,
}:

buildPythonPackage rec {
  pname = "explorerscript";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "explorerscript";
    tag = version;
    hash = "sha256-KjMPg3GfnEr2DtpHD/T3HKQWUM0WKTWKuv//3XXWShI=";
    # Include a pinned antlr4 fork used as a C++ library
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pybind11>=2.13.6, < 2.14" "pybind11" \
      --replace-fail "scikit-build-core>=0.10.7, < 0.11" "scikit-build-core"
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.pygments;

  build-system = [
    setuptools
    scikit-build-core
    pybind11
  ];

  dependencies = [
    igraph
  ];

  # The source include some auto-generated ANTLR code that could be recompiled, but trying that resulted in a crash while decompiling unionall.ssb.
  # We thus do not rebuild them.
  dontUseCmakeConfigure = true;
  optional-dependencies.pygments = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "explorerscript" ];

  pythonRelaxDeps = [
    "igraph"
  ];

  meta = {
    description = "Programming language + compiler/decompiler for creating scripts for Pokémon Mystery Dungeon Explorers of Sky";
    homepage = "https://github.com/SkyTemple/explorerscript";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
