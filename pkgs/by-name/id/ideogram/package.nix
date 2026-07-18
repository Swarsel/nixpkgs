{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gtk3,
  libgee,
  libx11,
  libxtst,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ideogram";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "cassidyjames";
    repo = "ideogram";
    rev = finalAttrs.version;
    sha256 = "1zkr7x022khn5g3sq2dkxzy1hiiz66vl81s3i5sb9qr88znh79p1";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    vala
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgee
    pantheon.granite
    libx11
    libxtst
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Insert emoji anywhere, even in non-native apps - designed for elementary OS";
    homepage = "https://github.com/cassidyjames/ideogram";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "com.github.cassidyjames.ideogram";
    teams = [ lib.teams.pantheon ];
  };

})
