{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  installShellFiles,
  libusb1,
  libzip,
  openssl,
  pkg-config,
  tinyxml-2,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nxpmicro-mfgtools";
  version = "1.5.243";

  src = fetchFromGitHub {
    owner = "nxp-imx";
    repo = "mfgtools";
    rev = "uuu_${finalAttrs.version}";
    sha256 = "sha256-+m3r/QxOnTjemqIaZ/2cxDHtHlw7qxu9PbTsQYyMaEY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    bzip2
    libusb1
    libzip
    openssl
    tinyxml-2
    zstd
  ];

  preConfigure = "echo ${finalAttrs.version} > .tarball-version";

  postInstall = ''
    # rules printed by the following invocation are static,
    # they come from hardcoded configs in libuuu/config.cpp:48
    $out/bin/uuu -udev > udev-rules 2>stderr.txt
    rules_file="$(cat stderr.txt|grep '1: put above udev run into'|sed 's|^.*/||')"
    install -D udev-rules "$out/lib/udev/rules.d/$rules_file"
    installShellCompletion --cmd uuu \
      --bash ../snap/local/bash-completion/universal-update-utility
  '';

  doInstallCheck = true;

  meta = {
    description = "Freescale/NXP I.MX chip image deploy tools";

    longDescription = ''
      UUU (Universal Update Utility) is a command line tool, evolved out of
      MFGTools (aka MFGTools v3).

      One of the main purposes is to upload images to I.MX SoC's using at least
      their boot ROM.

      With time, the need for an update utility portable to Linux and Windows
      increased. UUU has the same usage on both Windows and Linux. It means the same
      script works on both OS.
    '';

    homepage = "https://github.com/NXPmicro/mfgtools";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      bmilanov
      jraygauthier
    ];

    platforms = lib.platforms.all;
    mainProgram = "uuu";
  };
})
