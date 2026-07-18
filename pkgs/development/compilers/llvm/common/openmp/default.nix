{
  lib,
  stdenv,
  clang-unwrapped,
  cmake,
  getVersionFile,
  lit,
  llvm,
  llvm_meta,
  ninja,
  openmpCheckPhaseHook,
  perl,
  pkg-config,
  python3,
  release_version,
  runCommand,
  version,
  devExtraCmakeFlags ? [ ],
  monorepoSrc ? null,
  ompdGdbSupport ? ompdSupport,
  ompdSupport ? true,
  src ? null,
}:

assert lib.assertMsg (ompdGdbSupport -> ompdSupport) "OMPD GDB support requires OMPD support!";

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "openmp";

  src =
    if monorepoSrc != null then
      runCommand "openmp-src-${version}" { inherit (monorepoSrc) passthru; } ''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/cmake "$out"
        cp -r ${monorepoSrc}/openmp "$out"
      ''
    else
      src;

  outputs = [
    "out"
    "dev"
  ];

  patches =
    lib.optional (lib.versionOlder release_version "19") (getVersionFile "openmp/fix-find-tool.patch")
    ++ [
      (getVersionFile "openmp/run-lit-directly.patch")
    ];

  nativeBuildInputs = [
    cmake
    python3
    perl
    ninja
    pkg-config
    lit
  ];

  buildInputs = [
    llvm
  ]
  ++ lib.optionals (ompdSupport && ompdGdbSupport) [
    python3
  ];

  cmakeFlags = [
    (lib.cmakeBool "LIBOMP_ENABLE_SHARED" (
      !stdenv.hostPlatform.isStatic && stdenv.hostPlatform.hasSharedLibraries
    ))
    (lib.cmakeBool "LIBOMP_OMPD_SUPPORT" ompdSupport)
    (lib.cmakeBool "LIBOMP_OMPD_GDB_SUPPORT" ompdGdbSupport)
    (lib.cmakeFeature "CLANG_TOOL" "${clang-unwrapped}/bin/clang")
    (lib.cmakeFeature "OPT_TOOL" "${llvm}/bin/opt")
    (lib.cmakeFeature "LINK_TOOL" "${llvm}/bin/llvm-link")
  ]
  ++ devExtraCmakeFlags;

  doCheck = false;

  preCheck = ''
    patchShebangs ../tools/archer/tests/deflake.bash
  '';

  checkTarget = "check-openmp";

  propagatedNativeBuildInputs = [
    openmpCheckPhaseHook
  ];

  sourceRoot = "${finalAttrs.src.name}/openmp";

  meta = llvm_meta // {
    description = "Support for the OpenMP language";

    longDescription = ''
      The OpenMP subproject of LLVM contains the components required to build an
      executable OpenMP program that are outside the compiler itself.
      Contains the code for the runtime library against which code compiled by
      "clang -fopenmp" must be linked before it can run and the library that
      supports offload to target devices.
    '';

    homepage = "https://openmp.llvm.org/";

    # "All of the code is dual licensed under the MIT license and the UIUC
    # License (a BSD-like license)":
    license = with lib.licenses; [
      mit
      ncsa
    ];
  };
})
