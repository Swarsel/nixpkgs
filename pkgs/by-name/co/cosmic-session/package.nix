{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  dbus,
  just,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-session";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-nKrdjvD1dcFvwhCiruM/bxrh8CYOWnoVgJj/2nkfEFg=";
  };

  postPatch = ''
    substituteInPlace data/start-cosmic \
      --replace-fail '/usr/bin/cosmic-session' "$out/bin/cosmic-session" \
      --replace-fail '/usr/bin/dbus-run-session' "${lib.getBin dbus}/bin/dbus-run-session"
    substituteInPlace data/cosmic.desktop \
      --replace-fail '/usr/bin/start-cosmic' "$out/bin/start-cosmic"
  '';

  nativeBuildInputs = [ just ];
  buildInputs = [ bash ];
  cargoHash = "sha256-5dLG40X+yxJo566guyHqOCLNp+uNSE+HONS8GIDm58A=";
  env.ORCA = "orca"; # get orca from $PATH
  __structuredAttrs = true;
  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cosmic_dconf_profile"
    "${placeholder "out"}/etc/dconf/profile/cosmic"
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  separateDebugInfo = true;

  passthru = {
    providedSessions = [ "cosmic" ];

    tests = {
      inherit (nixosTests)
        cosmic
        cosmic-autologin
        cosmic-noxwayland
        cosmic-autologin-noxwayland
        ;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "epoch-(.*)"
      ];
    };
  };

  meta = {
    description = "Session manager for the COSMIC desktop environment";
    homepage = "https://github.com/pop-os/cosmic-session";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-session";
    teams = [ lib.teams.cosmic ];
  };
})
