{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cargo,
  libadwaita,
  libsecret,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  tinysparql,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "health";
  version = "0.95.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "health";
    rev = version;
    hash = "sha256-PrNPprSS98yN8b8yw2G6hzTSaoE65VbsM3q7FVB4mds=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    blueprint-compiler
  ];

  buildInputs = [
    libadwaita
    libsecret
    tinysparql
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-eR1ZGtTZQNhofFUEjI7IX16sMKPJmAl7aIFfPJukecg=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Health tracking app for the GNOME desktop";
    homepage = "https://apps.gnome.org/app/dev.Cogitri.Health";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "dev.Cogitri.Health";
    teams = [ lib.teams.gnome-circle ];
  };
}
