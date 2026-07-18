{
  lib,
  stdenv,
  fetchFromGitHub,
  busybox,
  cmake,
  gnugrep,
  python3,
  rocm-cmake,
  rocm-runtime,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocminfo";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-0esRBEXVibC2uzyonpc0ABNNHQ2NAWZrBmmg6p1zP0c=";

    sparseCheckout = [
      "projects/rocminfo"
      "shared"
    ];
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    rocm-cmake
    python3
  ];

  buildInputs = [ rocm-runtime ];
  cmakeFlags = [ "-DROCRTST_BLD_TYPE=Release" ];

  prePatch = ''
    patchShebangs rocm_agent_enumerator
    sed 's,lsmod | grep ,${busybox}/bin/lsmod | ${gnugrep}/bin/grep ,' -i rocminfo.cc
  '';

  sourceRoot = "${finalAttrs.src.name}/projects/rocminfo";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "ROCm Application for Reporting System Info";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/rocminfo";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    mainProgram = "rocminfo";
    teams = [ lib.teams.rocm ];
  };
})
