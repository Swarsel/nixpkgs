{
  lib,
  fetchFromGitHub,
  buildGoModule,
  clang,
  elfutils,
  libbpf,
  makeWrapper,
  nixosTests,
  pkg-config,
  testers,
  tracee,
  zlib,
  zstd,
}:

buildGoModule (finalAttrs: {
  pname = "tracee";
  version = "0.23.2";

  # src = /home/tim/repos/tracee;
  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "tracee";
    # project has branches and tags of the same name
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rf1pa9e6t002ltg40xZZVpE5OL9Vl02Xcn2Ux0To408=";
  };

  outputs = [
    "out"
    "lib"
    "share"
  ];

  patches = [
    ./0001-fix-do-not-build-libbpf.patch
  ];

  nativeBuildInputs = [
    clang
    pkg-config
  ];

  buildInputs = [
    elfutils
    libbpf
    zlib.dev
    zstd.dev
  ];

  vendorHash = "sha256-2+4UN9WB6eGzedogy5dMvhHj1x5VeUUkDM0Z28wKQgM=";

  makeFlags = [
    "RELEASE_VERSION=v${finalAttrs.version}"
    "GO_DEBUG_FLAG=-s -w"
    # don't actually need git but the Makefile checks for it
    "CMD_GIT=echo"
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p ./dist
    make $makeFlags ''${enableParallelBuilding:+-j$NIX_BUILD_CORES} bpf all
    runHook postBuild
  '';

  # tests require a separate go module
  # integration tests are ran within a nixos vm
  # see passthru.tests.integration
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $lib/lib/tracee $share/share/tracee

    mv ./dist/{tracee,signatures} $out/bin/
    mv ./dist/tracee.bpf.o $lib/lib/tracee/
    mv ./cmd/tracee-rules/templates $share/share/tracee/

    runHook postInstall
  '';

  enableParallelBuilding = true;

  # needed to build bpf libs
  hardeningDisable = [
    "stackprotector"
    "zerocallusedregs"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "tracee version";
      package = tracee;
    };

    integration = nixosTests.tracee;
    integration-test-cli = import ./integration-tests.nix { inherit lib tracee makeWrapper; };
  };

  meta = {
    description = "Linux Runtime Security and Forensics using eBPF";

    longDescription = ''
      Tracee is a Runtime Security and forensics tool for Linux. It is using
      Linux eBPF technology to trace your system and applications at runtime,
      and analyze collected events to detect suspicious behavioral patterns. It
      is delivered as a Docker image that monitors the OS and detects suspicious
      behavior based on a pre-defined set of behavioral patterns.
    '';

    homepage = "https://aquasecurity.github.io/tracee/latest/";
    changelog = "https://github.com/aquasecurity/tracee/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      # general license
      asl20
      # pkg/ebpf/c/*
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ jk ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "tracee";

    outputsToInstall = [
      "out"
      "share"
    ];
  };
})
