{
  lib,
  stdenv,
  # nativeBuildInputs
  cargo,
  desktop-file-utils,
  fetchFromCodeberg,
  # buildInputs
  gdk-pixbuf,
  gettext,
  graphene,
  gtk4,
  gtksourceview5,
  libadwaita,
  libspelling,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pango,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "typesetter";
  version = "0.13.5";

  src = fetchFromCodeberg {
    owner = "haydn";
    repo = "typesetter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sJUuc7Ado0NFbLrnO3WVxgMA2l5Uh7X0uLvJVhgwwPA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    gettext # msgfmt
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    graphene
    gtk4
    gtksourceview5
    libadwaita
    libspelling
    openssl
    pango
  ];

  env.OPENSSL_NO_VENDOR = true;
  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-E2ADu5jo8ulXGIw+vd9m4oFcxMMvo85oIetsIJy9ql4=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalist, local-first Typst editor";
    homepage = "https://codeberg.org/haydn/typesetter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "typesetter";
  };
})
