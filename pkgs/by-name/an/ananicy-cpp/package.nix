{
  lib,
  fetchFromGitLab,
  bpftools,
  clangStdenv,
  cmake,
  elfutils,
  libbpf,
  nlohmann_json,
  pcre2,
  pkg-config,
  spdlog,
  systemd,
  zlib,
  withBpf ? true,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "ananicy-cpp";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "ananicy-cpp";
    repo = "ananicy-cpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Nl7Ugj5VPHwW85GJ44luUc2e95kFCanQhDRopGH9nTU=";
    fetchSubmodules = true;
  };

  patches = [
    ./match-wrappers.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals withBpf [
    bpftools
  ];

  buildInputs = [
    pcre2
    spdlog
    nlohmann_json
    systemd
    zlib
  ]
  ++ lib.optionals withBpf [
    libbpf
    elfutils
  ];

  cmakeFlags = [
    (lib.mapAttrsToList lib.cmakeBool {
      "BPF_BUILD_LIBBPF" = false;
      "ENABLE_REGEX_SUPPORT" = true;
      "ENABLE_SYSTEMD" = true;
      "USE_BPF_PROC_IMPL" = withBpf;
      "USE_EXTERNAL_FMTLIB" = true;
      "USE_EXTERNAL_JSON" = true;
      "USE_EXTERNAL_SPDLOG" = true;
    })
    (lib.cmakeFeature "VERSION" finalAttrs.version)
  ];

  postInstall = ''
    rm -rf "$out"/include
    rm -rf "$out"/lib/cmake
  '';

  # BPF A call to built-in function '__stack_chk_fail' is not supported.
  hardeningDisable = [
    "stackprotector"
    "zerocallusedregs"
  ];

  meta = {
    description = "Rewrite of ananicy in c++ for lower cpu and memory usage";
    homepage = "https://gitlab.com/ananicy-cpp/ananicy-cpp";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      artturin
      johnrtitor
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ananicy-cpp";
  };
})
