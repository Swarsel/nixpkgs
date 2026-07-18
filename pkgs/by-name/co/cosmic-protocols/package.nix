{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "cosmic-protocols";
  version = "0-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-protocols";
    rev = "e95d89504513e1407f89a189aca328fbecc9eeef";
    hash = "sha256-u1Ur9lPm2HE60jCEJVhKtbGYfzV8pdiDjrsGwgKf3nA=";
  };

  strictDeps = true;
  nativeBuildInputs = [ wayland-scanner ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  __structuredAttrs = true;

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
        "--version"
        "branch=HEAD"
      ];
    };
  };

  meta = {
    description = "Additional wayland-protocols used by the COSMIC desktop environment";
    homepage = "https://github.com/pop-os/cosmic-protocols";

    license = with lib.licenses; [
      mit
      gpl3Only
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.cosmic ];
  };
}
