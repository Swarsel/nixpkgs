{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bison,
  libx11,
  libxkbfile,
  nix-update-script,
  pkg-config,
  testers,
  util-macros,
  xkeyboard-config,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xkbcomp";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xkbcomp";
    tag = "xkbcomp-${finalAttrs.version}";
    hash = "sha256-nkyBjIOX9Qr0K+R0JcvJ7egI0a8Zh/tyhZvG7E+VlZU=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    bison
  ];

  buildInputs = [
    util-macros # unused dependency but the build fails if pkg-config can't find it
    libx11
    libxkbfile
    xorgproto
  ];

  configureFlags = [ "--with-xkb-config-root=${xkeyboard-config}/share/X11/xkb" ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xkbcomp-(.*)" ]; };
  };

  meta = {
    description = "XKB keyboard description compiler";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xkbcomp";

    license = with lib.licenses; [
      hpnd
      mitOpenGroup
      hpndDec
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xkbcomp";
    pkgConfigModules = [ "xkbcomp" ];
  };
})
