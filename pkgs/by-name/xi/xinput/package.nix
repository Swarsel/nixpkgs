{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  nix-update-script,
  pkg-config,
  util-macros,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xinput";
  version = "1.6.4";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xinput";
    tag = "xinput-${finalAttrs.version}";
    hash = "sha256-EsSytLzwAHMwseW4pD/c+/J1MaCWPsE7RPoMIwT96yk=";
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
    libxext
    libxi
    libxinerama
    libxrandr
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xinput-(.*)" ]; };
  };

  meta = {
    description = "Utility to configure and test XInput devices";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xinput";

    license = with lib.licenses; [
      hpndSellVariant
      mit
    ];

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.unix;
    mainProgram = "xinput";
  };
})
