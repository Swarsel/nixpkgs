{
  lib,
  stdenv,
  fetchFromGitHub,
  # bees-service-wrapper
  bash,
  # Build inputs
  btrfs-progs,
  coreutils,
  makeWrapper,
  nixosTests,
  python3Packages,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bees";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "Zygo";
    repo = "bees";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qaiRWRd9+ElJ40QGOS3AxT2NvF3phQCyPnVz6RfTt8c=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3Packages.markdown # documentation build
  ];

  buildInputs = [
    btrfs-progs # for btrfs/ioctl.h
    util-linux # for uuid.h
  ];

  makeFlags = [
    "SHELL=bash"
    "PREFIX=$(out)"
    "ETC_PREFIX=$(out)/etc"
    "BEES_VERSION=${finalAttrs.version}"
    "SYSTEMD_SYSTEM_UNIT_DIR=$(out)/etc/systemd/system"
  ];

  buildFlags = [
    "ETC_PREFIX=/var/run/bees/configs"
  ];

  preBuild = ''
    git() { if [[ $1 = describe ]]; then echo ${finalAttrs.version}; else command git "$@"; fi; }
    export -f git
  '';

  postBuild = ''
    unset -f git
  '';

  postInstall = ''
    makeWrapper ${./bees-service-wrapper} "$out"/bin/bees-service-wrapper \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          util-linux
          btrfs-progs
        ]
      } \
      --set beesd_bin "$out"/lib/bees/bees
  '';

  passthru.tests = {
    smoke-test = nixosTests.bees;
  };

  meta = {
    description = "Block-oriented BTRFS deduplication service";
    longDescription = "Best-Effort Extent-Same: bees finds not just identical files, but also identical extents within files that differ";
    homepage = "https://github.com/Zygo/bees";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
