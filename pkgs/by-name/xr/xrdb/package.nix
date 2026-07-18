{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxmu,
  mcpp,
  nix-update-script,
  pkg-config,
  util-macros,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xrdb";
  version = "1.2.2";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xrdb";
    tag = "xrdb-${finalAttrs.version}";
    hash = "sha256-XCi/E6tVaLYGRsMWJalCl1J8VIT4xV6KFuo+K//LQGY=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ];

  buildInputs = [
    xorgproto
    libx11
    libxmu
  ];

  # replace gcc with mcpp as preprocessor to reduce the closure size
  # see https://github.com/NixOS/nixpkgs/issues/9480
  configureFlags = [ "--with-cpp=${lib.getExe mcpp}" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=xrdb-(.*)" ]; };

  meta = {
    description = "X resource database utility";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xrdb";

    license = with lib.licenses; [
      hpndDec
      mitOpenGroup
    ];

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.unix;
    mainProgram = "xrdb";
  };
})
