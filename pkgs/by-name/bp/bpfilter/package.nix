{
  lib,
  fetchFromGitHub,
  bison,
  clangStdenv,
  cmake,
  cmocka,
  doxygen,
  flex,
  gitMinimal,
  lcov,
  libbpf,
  libelf,
  libnl,
  nix-update-script,
  pkg-config,
  sphinx,
  tinyxxd,
  zlib,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "bpfilter";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "bpfilter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mlJQIvOWF8WL4pX8KTKM1ddEFva+dvj5m2S3sWQJsKE=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    bison
    cmake
    cmocka
    doxygen
    flex
    lcov
    pkg-config
    sphinx
    tinyxxd
  ];

  buildInputs = [
    libbpf
    libelf
    libnl
    zlib
  ];

  cmakeFlags = [
    "-DDEFAULT_PROJECT_VERSION=${finalAttrs.version}"
    "-DNO_TESTS=1" # tries to clone nftables
    "-DNO_CHECKS=1"
    "-DNO_BENCHMARKS=1"
  ];

  preFixup = ''
    substituteInPlace $out/lib/systemd/system/bpfilter.service --replace-fail /usr/sbin/bpfilter $out/bin/bpfilter

    # workaround for https://github.com/NixOS/nixpkgs/issues/144170
    substituteInPlace $lib/lib/pkgconfig/bpfilter.pc --replace-fail \''${prefix}/ ""
  '';

  # invalid with -target bpf
  hardeningDisable = [ "zerocallusedregs" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "BPF-based packet filtering framework";
    homepage = "https://bpfilter.io";
    changelog = "https://github.com/facebook/bpfilter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.jmbaur ];
    platforms = lib.platforms.linux;
    mainProgram = "bpfilter";
  };
})
