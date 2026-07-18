{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  cmake,
  libusb1,
  makeWrapper,
  pkg-config,
  qt5,
  wget,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imsprog";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "bigbigmdm";
    repo = "IMSProg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VV4qlMd4hj37AIRSMY/EzbJEz3gRLb9Q38ujwQddi0M=";
  };

  # change default hardcoded path for chip database file, udev rules et al
  postPatch = ''
    while IFS= read -r -d "" file ; do
      substituteInPlace "$file" \
        --replace-quiet '/usr/bin/' "$out/bin/" \
        --replace-quiet '/usr/lib/' "$out/lib/" \
        --replace-quiet '/usr/share/' "$out/share/"
    done < <(grep --files-with-matches --null --recursive '/usr/' .)
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    qt5.wrapQtAppsHook
    qt5.qttools
  ];

  buildInputs = [
    bash # for patching the shebang in bin/IMSProg_database_update
    libusb1
    qt5.qtbase
    qt5.qtwayland
  ];

  doInstallCheck = true;

  postFixup = ''
    wrapProgram $out/bin/IMSProg_database_update \
      --prefix PATH : "${
        lib.makeBinPath [
          wget
          zenity
        ]
      }"
  '';

  meta = {
    description = "Free I2C, MicroWire and SPI EEPROM/Flash chip programmer tool for CH341A device";
    homepage = "https://github.com/bigbigmdm/IMSProg";
    changelog = "https://github.com/bigbigmdm/IMSProg/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      gpl3Plus
      gpl2Plus
      lgpl21Only
    ];

    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.unix;
    mainProgram = "IMSProg";
  };
})
