{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telegraph";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "fkinoshita";
    repo = "Telegraph";
    rev = "v${finalAttrs.version}";
    hash = "sha256-m36YHIo1PaDunnC12feSAbwwG1+E7s90fzOKskHtIag=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    (python3.withPackages (
      ps: with ps; [
        pygobject3
      ]
    ))
  ];

  meta = {
    description = "Write and decode Morse";
    homepage = "https://github.com/fkinoshita/Telegraph";
    changelog = "https://github.com/fkinoshita/Telegraph/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ michaelgrahamevans ];
    platforms = lib.platforms.linux;
    mainProgram = "telegraph";
  };
})
