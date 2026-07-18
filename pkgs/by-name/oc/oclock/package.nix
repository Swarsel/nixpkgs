{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxext,
  libxkbfile,
  libxmu,
  libxt,
  nix-update-script,
  pkg-config,
  util-macros,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "oclock";
  version = "1.0.6";

  src = fetchFromGitLab {
    owner = "app";
    repo = "oclock";
    tag = "oclock-${finalAttrs.version}";
    hash = "sha256-rk+PV2iEoqRwXN8bq0kCPk0qW0VPwid1T1XrH+Y9yLw=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    util-macros
    autoreconfHook
  ];

  buildInputs = [
    libxkbfile
    libx11
    libxext
    libxmu
    libxt
  ];

  installFlags = [ "appdefaultdir=$(out)/share/X11/app-defaults" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=oclock-(.*)" ]; };

  meta = {
    description = "simple analog clock using the X11 SHAPE extension to make a round window";
    homepage = "https://gitlab.freedesktop.org/xorg/app/oclock";

    license = with lib.licenses; [
      mitOpenGroup
      x11
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "oclock";
  };
})
