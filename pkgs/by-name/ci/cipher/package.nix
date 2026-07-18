{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  gtk3,
  libgee,
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
  pname = "cipher";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "arshubham";
    repo = "cipher";
    tag = finalAttrs.version;
    sha256 = "00azc5ck17zkdypfza6x1viknwhimd9fqgk2ybff3mx6aphmla7a";
  };

  postPatch = ''
    substituteInPlace data/com.github.arshubham.cipher.desktop.in \
      --replace "gio" "${glib.bin}/bin/gio"
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    gettext
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
    pantheon.granite
    libgee
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple application for encoding and decoding text, designed for elementary OS";
    homepage = "https://github.com/arshubham/cipher";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xiorcale ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.arshubham.cipher";
    teams = [ lib.teams.pantheon ];
  };
})
