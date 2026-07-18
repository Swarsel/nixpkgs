{
  lib,
  atk,
  fetchFromSourcehut,
  glib,
  gobject-introspection,
  gtk3,
  libhandy,
  libnotify,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "caerbannog";
  version = "0.3";

  src = fetchFromSourcehut {
    owner = "~craftyguy";
    repo = "caerbannog";
    tag = finalAttrs.version;
    sha256 = "0wqkb9zcllxm3fdsr5lphknkzy8r1cr80f84q200hbi99qql1dxh";
  };

  nativeBuildInputs = [
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    atk
    libhandy
    libnotify
    pango
  ];

  propagatedBuildInputs = with python3.pkgs; [
    anytree
    fuzzyfinder
    gpg
    pygobject3
  ];

  pyproject = false;

  meta = {
    description = "Mobile-friendly Gtk frontend for password-store";
    homepage = "https://sr.ht/~craftyguy/caerbannog/";
    changelog = "https://git.sr.ht/~craftyguy/caerbannog/refs/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "caerbannog";
  };
})
