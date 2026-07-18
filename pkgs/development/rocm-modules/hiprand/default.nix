{
  lib,
  stdenv,
  fetchFromGitHub,
  clr,
  cmake,
  gtest,
  rocm-cmake,
  rocmUpdateScript,
  rocrand,
  buildTests ? false,
  gpuTargets ? clr.localGpuTargets or [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hiprand";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-libraries";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-bjcwjN1dNukhoDAbiSpATlK6dtAwM8bOJTe3IjhdwwY=";

    sparseCheckout = [
      "projects/hiprand"
      "shared"
    ];
  };

  outputs = [
    "out"
  ]
  ++ lib.optionals buildTests [
    "test"
  ];

  nativeBuildInputs = [
    cmake
    rocm-cmake
    clr
  ];

  buildInputs = [ rocrand ] ++ (lib.optionals buildTests [ gtest ]);

  cmakeFlags = [
    "-DHIP_ROOT_DIR=${clr}"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ]
  ++ lib.optionals (gpuTargets != [ ]) [
    "-DAMDGPU_TARGETS=${lib.concatStringsSep ";" gpuTargets}"
  ]
  ++ lib.optionals buildTests [
    "-DBUILD_TEST=ON"
  ];

  postInstall = lib.optionalString buildTests ''
    mkdir -p $test/bin
    mv $out/bin/test_* $test/bin
    rm -r $out/bin/hipRAND
    # Fail if bin/ isn't actually empty
    rmdir $out/bin
  '';

  sourceRoot = "${finalAttrs.src.name}/projects/hiprand";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "HIP wrapper for rocRAND and cuRAND";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/hiprand";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
