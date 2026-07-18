{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  curl,
  gtkmm3,
  libhandy,
  libopus,
  libpulseaudio,
  libsecret,
  libsodium,
  makeDesktopItem,
  makeWrapper,
  nlohmann_json,
  pcre2,
  pkg-config,
  spdlog,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abaddon";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "uowuo";
    repo = "abaddon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fSNXMbyYmUOA4x911/an02fhhhWe6a4xlLVb2DIqIOE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    curl
    gtkmm3
    libhandy
    libopus
    libsecret
    libsodium
    nlohmann_json
    pcre2
    spdlog
    sqlite
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/abaddon
    cp -r ../res/{css,res} $out/share/abaddon
    mkdir $out/bin
    cp abaddon $out/bin
    wrapProgram $out/bin/abaddon \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          alsa-lib
          libpulseaudio
        ]
      }" \
      --chdir $out/share/abaddon

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "InstantMessaging"
      ];

      desktopName = "Abaddon";
      exec = finalAttrs.pname;
      genericName = finalAttrs.meta.description;
      mimeTypes = [ "x-scheme-handler/discord" ];
      name = finalAttrs.pname;
      startupWMClass = finalAttrs.pname;
    })
  ];

  meta = {
    description = "Discord client reimplementation, written in C++";
    homepage = "https://github.com/uowuo/abaddon";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ choco98 ];
    platforms = lib.platforms.linux;
    mainProgram = "abaddon";
  };
})
