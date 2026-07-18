{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  ffmpeg,
  gtk3,
  imagemagick,
  meson,
  ninja,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

let
  inherit (pantheon) granite;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ciano";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "robertsanseries";
    repo = "ciano";
    rev = finalAttrs.version;
    hash = "sha256-nubm6vBWwsHrrmvFAL/cIzYPxg9B1EhnpC79IJMNuFY=";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    ffmpeg
    imagemagick
    granite
    gtk3
  ];

  postFixup =
    let
      binPath = lib.makeBinPath [
        ffmpeg
        imagemagick
      ];
    in
    ''
      wrapProgram $out/bin/com.github.robertsanseries.ciano \
         --prefix PATH : ${binPath} "''${gappsWrapperArgs[@]}"
      ln -s $out/bin/com.github.robertsanseries.ciano $out/bin/ciano
    '';

  dontWrapGApps = true;

  meta = {
    description = "Multimedia file converter focused on simplicity";
    homepage = "https://github.com/robertsanseries/ciano";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
