{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  flex,
  hexdump,
  libxml2,
  llvmPackages,
  openexr,
  openimageio,
  partio,
  pugixml,
  python3Packages,
  robin-map,
  zlib,
}:

let
  inherit (llvmPackages) clang libclang llvm;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openshadinglanguage";
  version = "1.15.5.0";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "OpenShadingLanguage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-edtYKN2obQexQtclrIUflm3upc14MhHQ7eLvit5Hqq0=";
  };

  postPatch = ''
    substituteInPlace src/cmake/modules/FindLLVM.cmake \
      --replace-fail "NO_DEFAULT_PATH" ""
  '';

  nativeBuildInputs = [
    bison
    clang
    cmake
    flex
  ];

  buildInputs = [
    hexdump
    libclang
    llvm
    openexr
    openimageio
    partio
    pugixml
    python3Packages.pybind11
    robin-map
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libxml2
  ];

  propagatedBuildInputs = [
    python3Packages.openimageio
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_QT" false)

    # Build system implies llvm-config and llvm-as are in the same directory.
    # Override defaults.
    (lib.cmakeFeature "LLVM_BC_GENERATOR" "${clang}/bin/clang++")
    (lib.cmakeFeature "LLVM_CONFIG" "${llvm.dev}/bin/llvm-config")
    (lib.cmakeFeature "LLVM_DIRECTORY" "${llvm}")
  ];

  preConfigure = ''
    patchShebangs src/liboslexec/serialize-bc.bash
  '';

  postFixup = ''
    substituteInPlace "$out"/lib/pkgconfig/*.pc \
      --replace '=''${exec_prefix}//' '=/'
  '';

  meta = {
    description = "Advanced shading language for production GI renderers";
    homepage = "http://openshadinglanguage.org";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.amarshall ];
    platforms = lib.platforms.unix;
  };
})
