{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxext,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "9menu";
  version = "1.11";

  src = fetchFromGitHub {
    owner = "arnoldrobbins";
    repo = "9menu";
    tag = "9menu-release-${finalAttrs.version}";
    hash = "sha256-J0vHArLH8WDCOvbbF4TYd9b75+5UkhnVdhbbeiUJ4SM=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    libx11
    libxext
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "9menu-release-([0-9.]+)"
    ];
  };

  meta = {
    description = "Simple X11 menu program for running commands";
    homepage = "https://github.com/arnoldrobbins/9menu";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = libx11.meta.platforms;
    mainProgram = "9menu";
  };
})
