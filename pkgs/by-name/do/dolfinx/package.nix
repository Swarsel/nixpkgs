{
  lib,
  stdenv,
  fetchFromGitHub,
  adios2,
  boost,
  catch2_3,
  cmake,
  kahip,
  petsc,
  pkg-config,
  pugixml,
  python3Packages,
  slepc,
  spdlog,
  withParmetis ? false,
}:
let
  dolfinxPackages = petsc.petscPackages.overrideScope (
    final: prev: {
      adios2 = final.callPackage adios2.override { };
      kahip = final.callPackage kahip.override { };
      slepc = final.callPackage slepc.override { };
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dolfinx";
  version = "0.11.0.post0";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "dolfinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-brmU6AA7lN4TyHjHcg4mHUIj/OvJ16pfspEN95M4oOE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    dolfinxPackages.kahip
    dolfinxPackages.scotch
  ]
  ++ lib.optional withParmetis dolfinxPackages.parmetis;

  propagatedBuildInputs = [
    spdlog
    pugixml
    boost
    petsc
    dolfinxPackages.hdf5
    dolfinxPackages.slepc
    dolfinxPackages.adios2
    python3Packages.fenics-basix
    python3Packages.fenics-ffcx
  ];

  cmakeFlags = [
    (lib.cmakeBool "DOLFINX_ENABLE_ADIOS2" true)
    (lib.cmakeBool "DOLFINX_ENABLE_PETSC" true)
    (lib.cmakeBool "DOLFIN_ENABLE_PARMETIS" withParmetis)
    (lib.cmakeBool "DOLFINX_ENABLE_SCOTCH" true)
    (lib.cmakeBool "DOLFINX_ENABLE_SLEPC" true)
    (lib.cmakeBool "DOLFINX_ENABLE_KAHIP" true)
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  cmakeDir = "../cpp";

  passthru.tests = {
    unittests = stdenv.mkDerivation {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-unittests";

      nativeBuildInputs = [
        cmake
        pkg-config
      ];

      buildInputs = [ finalAttrs.finalPackage ];
      doCheck = true;
      nativeCheckInputs = [ catch2_3 ];

      installPhase = ''
        touch $out
      '';

      cmakeDir = "../cpp/test";
    };
  };

  meta = {
    description = "Computational environment of FEniCSx and implements the FEniCS Problem Solving Environment in C++ and Python";
    homepage = "https://fenicsproject.org";
    changelog = "https://github.com/fenics/dolfinx/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd2
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/fenics/dolfinx";
  };
})
