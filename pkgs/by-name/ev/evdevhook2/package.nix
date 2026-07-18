{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libevdev,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  testers,
  udev,
  vala,
}:

let
  # https://github.com/v1993/evdevhook2/blob/main/subprojects/gcemuhook.wrap
  gcemuhook = fetchFromGitHub {
    hash = "sha256-CPjSuKtoqSDKd+vEBgFy3qh33TkCVbxBEnwiBAkaADs=";
    name = "gcemuhook";
    owner = "v1993";
    repo = "gcemuhook";
    rev = "91ef61cca809f5f3b9fa6e5304aba284a56c06dc";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "evdevhook2";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "v1993";
    repo = "evdevhook2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6CnUYLgrGUM1ndGpbn/T7wkREUzQ1LsLMpkRRxyUZ50=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    libevdev
    libgee
    udev
  ];

  mesonBuildType = "release";

  postUnpack = ''
    ln -sf ${gcemuhook} source/subprojects/gcemuhook
  '';

  passthru = {
    tests.version = testers.testVersion {
      version = "Evdevhook ${finalAttrs.version}";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cemuhook UDP server for devices with modern Linux drivers";
    homepage = "https://github.com/v1993/evdevhook2";
    changelog = "https://github.com/v1993/evdevhook2/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.linux;
    mainProgram = "evdevhook2";
  };
})
