{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyPkgconfigItems,
  ctestCheckHook,
  gtest,
  makePkgconfigItem,
  testers,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kaitai-struct-cpp-stl-runtime";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_struct_cpp_stl_runtime";
    tag = finalAttrs.version;
    sha256 = "sha256-2glGPf08bkzvnkLpQIaG2qiy/yO+bZ14hjIaCKou2vU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    copyPkgconfigItems
    ctestCheckHook
  ];

  buildInputs = [
    zlib
    gtest
  ];

  doCheck = true;

  # https://github.com/kaitai-io/kaitai_struct_cpp_stl_runtime/issues/82
  pkgconfigItems = [
    (makePkgconfigItem rec {
      inherit (finalAttrs) version;
      inherit (finalAttrs.meta) description;
      cflags = [ "-I${variables.includedir}" ];

      libs = [
        "-L${variables.libdir}"
        "-lkaitai_struct_cpp_stl_runtime"
      ];

      name = "kaitai-struct-cpp-stl-runtime";

      variables = {
        includedir = "${placeholder "dev"}/include";
        libdir = "${placeholder "out"}/lib";
      };
    })
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Kaitai Struct C++ STL Runtime Library";
    homepage = "https://github.com/kaitai-io/kaitai_struct_cpp_stl_runtime";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fzakaria ];
    pkgConfigModules = [ "kaitai-struct-cpp-stl-runtime" ];
  };
})
