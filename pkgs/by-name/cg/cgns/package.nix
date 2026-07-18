{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  gfortran,
  hdf5,
  libGLU,
  libxmu,
  testers,
  tk,
  withTools ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cgns";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "cgns";
    repo = "cgns";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0cZtq8nVAHAubHD6IDofnh8N7xiNHQkbhXR5OpdhPQU=";
  };

  patches = [
    # Fixes crash for test_particlef on LoongArch64
    (fetchpatch2 {
      hash = "sha256-dtwTD8YqRm0NCXTDPRHmaPLTU17ZLzOyVii1aoGYge0=";
      url = "https://github.com/CGNS/CGNS/commit/0ea14abf6da44f13ca8a01117ad7af8eb405394c.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace src/cgnstools/tkogl/tkogl.c \
      --replace-fail "<tk-private/generic/tkInt.h>" "<tkInt.h>"
  '';

  nativeBuildInputs = [
    cmake
    gfortran
  ];

  buildInputs = [
    hdf5
  ]
  ++ lib.optionals withTools [
    tk
    libxmu
    libGLU
  ];

  cmakeFlags = [
    (lib.cmakeBool "CGNS_ENABLE_FORTRAN" true)
    (lib.cmakeBool "CGNS_ENABLE_LEGACY" true)
    (lib.cmakeBool "CGNS_ENABLE_HDF5" true)
    (lib.cmakeBool "HDF5_NEED_MPI" hdf5.mpiSupport)
    (lib.cmakeBool "CGNS_BUILD_CGNSTOOLS" withTools)
    (lib.cmakeBool "CGNS_ENABLE_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "CGNS_BUILD_SHARED" (!stdenv.hostPlatform.isStatic))
  ];

  doCheck = true;

  # Remove broken .desktop files
  postFixup = ''
    rm -f $out/bin/*.desktop
  '';

  enableParallelChecking = false;

  passthru.tests.cmake-config = testers.hasCmakeConfigModules {
    moduleNames = [ "cgns" ];
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "CFD General Notation System standard library";
    homepage = "https://cgns.github.io";
    changelog = "https://github.com/cgns/cgns/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ zlib ];
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/cgns/cgns";
  };
})
