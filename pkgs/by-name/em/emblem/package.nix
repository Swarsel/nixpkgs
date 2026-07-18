{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  glib,
  libadwaita,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "emblem";
  version = "1.6.0";

  src = fetchFromGitLab {
    owner = "design";
    repo = "emblem";
    tag = version;
    hash = "sha256-OqP6KLaDix4hR/AA+lfaMu4nZPqpAKfYzZu7tr+RUJI=";
    domain = "gitlab.gnome.org";
    # Temporary workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    group = "World";
  };

  nativeBuildInputs = [
    desktop-file-utils
    glib
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    libadwaita
    libxml2
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-J00zw8jOeMLjGyn2Gj4TA5vHjIWOw+x/XEIXMyBFMdw=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Generate project icons and avatars from a symbolic icon";
    homepage = "https://gitlab.gnome.org/World/design/emblem";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "emblem";
    teams = [ lib.teams.gnome-circle ];
  };
}
