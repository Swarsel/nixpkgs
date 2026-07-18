{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  clippy,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  poppler,
  rustPlatform,
  rustc,
  testers,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "citations";
  version = "0.10.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "citations";
    rev = finalAttrs.version;
    hash = "sha256-CnCXyKXB/wH6lt35370dh+lFhqdJLCJRGBs2WH+FCP0=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    glib
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    gtksourceview5
    libadwaita
    poppler
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang (
    lib.concatStringsSep " " [
      "-Wno-typedef-redefinition"
      "-Wno-unused-parameter"
      "-Wno-missing-field-initializers"
      "-Wno-incompatible-function-pointer-types"
    ]
  );

  doCheck = true;
  nativeCheckInputs = [ clippy ];

  preCheck = ''
    sed -i -e '/PATH=/d' ../src/meson.build
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    hash = "sha256-xEJe752Qr1s2d/9nfTpwDP+zxZKwx0UuEUwIf4wzJW4=";
  };

  passthru = {
    tests.version = testers.testVersion {
      command = "citations --help";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Manage your bibliographies using the BibTeX format";
    homepage = "https://apps.gnome.org/app/org.gnome.World.Citations";
    changelog = "https://gitlab.gnome.org/World/citations/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ benediktbroich ];
    platforms = lib.platforms.unix;
    mainProgram = "citations";
    teams = [ lib.teams.gnome-circle ];
  };
})
