{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  libadwaita,
  libgee,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pinit";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "ryonakano";
    repo = "pinit";
    rev = finalAttrs.version;
    hash = "sha256-v/GFgEStQPQxwnPiTCa8gSDj8jZqJkUqLRV/WfBx3Tc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libgee
  ];

  meta = {
    description = "Pin portable apps to the launcher";
    homepage = "https://github.com/ryonakano/pinit";

    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];

    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.ryonakano.pinit";
  };
})
