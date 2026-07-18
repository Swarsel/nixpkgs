{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  desktop-file-utils,
  gtk3,
  libgee,
  libhandy,
  meson,
  ninja,
  pantheon,
  pkg-config,
  python3,
  shared-mime-info,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnonograms";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "jeremypw";
    repo = "gnonograms";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TkEVjrwlr4Q5FsfcdY+9fxwaMq+DFs0RwGI2E+GT5Mk=";
  };

  postPatch = ''
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream
    python3
    shared-mime-info
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    pantheon.granite
    libgee
    libhandy
  ];

  meta = {
    description = "Nonograms puzzle game";

    longDescription = ''
      An implementation of the Japanese logic puzzle "Nonograms" written in
      Vala, allowing the user to:
      * Draw puzzles
      * Generate random puzzles of chosen difficulty
    '';

    homepage = "https://github.com/jeremypw/gnonograms";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "com.github.jeremypw.gnonograms";
  };
})
