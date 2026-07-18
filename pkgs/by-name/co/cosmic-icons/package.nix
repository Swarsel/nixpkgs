{
  lib,
  fetchFromGitHub,
  hicolor-icon-theme,
  just,
  nix-update-script,
  pop-icon-theme,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cosmic-icons";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-icons";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-QUTAYIQ6qAhjZK/9BZjJzTViECLUwO/MyaOqiRb1Ans=";
  };

  strictDeps = true;
  nativeBuildInputs = [ just ];

  propagatedBuildInputs = [
    pop-icon-theme
    hicolor-icon-theme
  ];

  __structuredAttrs = true;
  dontDropIconThemeCache = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    description = "System76 Cosmic icon theme for Linux";
    homepage = "https://github.com/pop-os/cosmic-icons";

    license = with lib.licenses; [
      cc-by-sa-40
    ];

    teams = [ lib.teams.cosmic ];
  };
})
