{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxkbfile,
  nix-update-script,
  pkg-config,
  util-macros,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xwd";
  version = "1.0.9";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xwd";
    tag = "xwd-${finalAttrs.version}";
    hash = "sha256-cEKm0c50qwWzGSkH1sdovNfN3dW1hmnaEDwuJKwxGdo=";
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
    libxkbfile
    libx11
    xorgproto
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=xwd-(.*)" ]; };

  meta = {
    description = "Utility to dump an image of an X window in XWD format";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xwd";

    license = with lib.licenses; [
      mitOpenGroup
      hpndSellVariant
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xwd";
  };
})
