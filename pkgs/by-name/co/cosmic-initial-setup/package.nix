{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  killall,
  libcosmicAppHook,
  libinput,
  nix-update-script,
  nixosTests,
  openssl,
  rustPlatform,
  udev,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-initial-setup";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-UABqbmbwW2ZBOO7mq16/h0s55VCWRF2yyf/1TaubC88=";
  };

  postPatch = ''
    # Installs in $out/etc/xdg/autostart instead of /etc/xdg/autostart
    substituteInPlace justfile \
      --replace-fail \
      "autostart-dst := rootdir / 'etc' / 'xdg' / 'autostart' / desktop-entry" \
      "autostart-dst := prefix / 'etc' / 'xdg' / 'autostart' / desktop-entry"
  '';

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  buildInputs = [
    killall
    libinput
    openssl
    udev
  ];

  cargoHash = "sha256-DESnl5NjakU4++Ep6CHxDZzHn+o0Gi0eREpXk5BN5iY=";

  env = {
    DISABLE_IF_EXISTS = "/iso/nix-store.squashfs";
    VERGEN_GIT_SHA = finalAttrs.src.tag;
  };

  preFixup = ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ killall ]})
  '';

  __structuredAttrs = true;
  # cargo-auditable fails during the build when compiling the `crabtime::function`
  # procedural macro. It panics because the `--out-dir` flag is not passed to
  # the rustc wrapper.
  #
  # Reported this issue upstream in:
  # https://github.com/rust-secure-code/cargo-auditable/issues/225
  auditable = false;
  buildFeatures = [ "nixos" ];
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  separateDebugInfo = true;

  passthru = {
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
    description = "COSMIC Initial Setup";
    homepage = "https://github.com/pop-os/cosmic-initial-setup";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-initial-setup";
    teams = [ lib.teams.cosmic ];
  };
})
