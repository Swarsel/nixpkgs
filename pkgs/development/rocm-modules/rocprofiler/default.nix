{
  lib,
  stdenv,
  fetchFromGitHub,
  aqlprofile,
  clang,
  clr,
  cmake,
  elfutils,
  gtest,
  libpciaccess,
  libxml2,
  llvm,
  mpi,
  numactl,
  python3Packages,
  rocdbgapi,
  rocm-core,
  rocm-device-libs,
  rocm-runtime,
  rocmUpdateScript,
  roctracer,
  symlinkJoin,
  gpuTargets ? clr.gpuTargets,
}:

let
  rocmtoolkit-merged = symlinkJoin {
    postBuild = ''
      rm -rf $out/nix-support
    '';

    name = "rocmtoolkit-merged";

    paths = [
      rocm-core
      rocm-runtime
      rocm-device-libs
      roctracer
      rocdbgapi
      clr
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rocprofiler";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-Wo0pymD8LsrdczdIUEEVe5x2Id//KIFkh40kliAQgWo=";
    fetchSubmodules = true;

    sparseCheckout = [
      "projects/rocprofiler"
      "shared"
    ];
  };

  postPatch = ''
    patchShebangs .

    substituteInPlace cmake_modules/rocprofiler_utils.cmake \
      --replace-fail 'function(ROCPROFILER_CHECKOUT_GIT_SUBMODULE)' 'function(ROCPROFILER_CHECKOUT_GIT_SUBMODULE)
      return()'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(ROCPROFILER_BUILD_TESTS ON)' ""

    substituteInPlace tests-v2/featuretests/profiler/CMakeLists.txt \
      --replace "--build-id=sha1" "--build-id=sha1 --rocm-path=${clr} --rocm-device-lib-path=${rocm-device-libs}/amdgcn/bitcode"

    substituteInPlace test/CMakeLists.txt \
      --replace "\''${ROCM_ROOT_DIR}/amdgcn/bitcode" "${rocm-device-libs}/amdgcn/bitcode"
  '';

  nativeBuildInputs = [
    cmake
    clang
    clr
    python3Packages.lxml
    python3Packages.cppheaderparser
    python3Packages.pyyaml
    python3Packages.barectf
    python3Packages.pandas
  ];

  buildInputs = [
    llvm.clang-unwrapped
    llvm.llvm
    numactl
    libpciaccess
    libxml2
    elfutils
    mpi
    gtest
    aqlprofile
  ];

  propagatedBuildInputs = [ rocmtoolkit-merged ];

  cmakeFlags = [
    "-DCMAKE_MODULE_PATH=${clr}/lib/cmake/hip"
    "-DHIP_ROOT_DIR=${clr}"
    "-DGPU_TARGETS=${lib.concatStringsSep ";" gpuTargets}"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  #HACK: rocprofiler's cmake doesn't add these deps properly
  env.CXXFLAGS = "-I${libpciaccess}/include -I${numactl.dev}/include -I${rocmtoolkit-merged}/include -I${elfutils.dev}/include -w";

  postInstall = ''
    # Why do these have the executable bit set?
    chmod -x $out/libexec/rocprofiler/counters/*.xml
    # rocprof shell script wants to find it in the same bin dir, easiest to symlink in
    ln -s ${clr}/bin/rocm_agent_enumerator $out/bin/rocm_agent_enumerator
  '';

  postFixup = ''
    patchelf $out/lib/*.so \
      --add-rpath ${aqlprofile}/lib \
      --add-needed libhsa-amd-aqlprofile64.so
  '';

  sourceRoot = "${finalAttrs.src.name}/projects/rocprofiler";
  passthru.rocmtoolkit-merged = rocmtoolkit-merged;
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Profiling with perf-counters and derived metrics";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/rocprofiler";
    license = with lib.licenses; [ mit ]; # mitx11
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
