{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cabextract,
  dmg2img,
  dtc,
  dumpifs,
  fontconfig,
  gnutar,
  jefferson,
  lz4,
  lzfse,
  lzo,
  lzop,
  makeBinaryWrapper,
  openssl_3,
  p7zip,
  pkg-config,
  python3,
  rustPlatform,
  sasquatch,
  sleuthkit,
  srec2bin,
  ubi_reader,
  ucl,
  uefi-firmware-parser,
  unrar,
  unyaffs,
  unzip,
  versionCheckHook,
  vmlinux-to-elf,
  xz,
  zlib,
  zstd,
  enableUnfree ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "binwalk";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "ReFirmLabs";
    repo = "binwalk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-em+jOnhCZH5EEJrhXTHmxiwpMcBr5oNU1+5IJ1H/oco=";
  };

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  # https://github.com/ReFirmLabs/binwalk/commits/master/dependencies
  buildInputs = [
    bzip2
    dtc
    fontconfig
    lzo
    openssl_3
    python3.pkgs.python-lzo
    ucl
    unzip
    xz
    zlib
  ];

  cargoHash = "sha256-cnJVeuvNNApEHqgZDcSgqkH3DKAr8+HkqXUH9defTCA=";

  # skip broken tests
  checkFlags = [
    "--skip=binwalk::Binwalk"
    "--skip=binwalk::Binwalk::scan"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "--skip=binwalk::Binwalk::analyze"
    "--skip=binwalk::Binwalk::extract"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=extractors::common::Chroot::append_to_file"
    "--skip=extractors::common::Chroot::carve_file"
    "--skip=extractors::common::Chroot::create_block_device"
    "--skip=extractors::common::Chroot::create_character_device"
    "--skip=extractors::common::Chroot::create_directory"
    "--skip=extractors::common::Chroot::create_fifo"
    "--skip=extractors::common::Chroot::create_file"
    "--skip=extractors::common::Chroot::create_socket"
    "--skip=extractors::common::Chroot::create_symlink"
    "--skip=extractors::common::Chroot::make_executable"
  ];

  postInstall = ''
    wrapProgram $out/bin/binwalk --suffix PATH : ${
      lib.makeBinPath (
        [
          p7zip
          cabextract
          dmg2img
          dumpifs
          jefferson
          vmlinux-to-elf
          lz4
          lzfse
          lzop
          sasquatch
          srec2bin
          gnutar
          sleuthkit
          ubi_reader
          uefi-firmware-parser
          unyaffs
          zstd
        ]
        ++ lib.optionals enableUnfree [ unrar ]
      )
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontUseCargoParallelTests = true;
  versionCheckProgramArg = "-V";

  meta = {
    description = "Firmware Analysis Tool";
    homepage = "https://github.com/ReFirmLabs/binwalk";
    changelog = "https://github.com/ReFirmLabs/binwalk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      koral
      felbinger
    ];

    platforms = lib.platforms.unix;
    mainProgram = "binwalk";
  };
})
