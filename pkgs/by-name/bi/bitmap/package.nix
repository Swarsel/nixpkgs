{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxaw,
  libxmu,
  libxt,
  nix-update-script,
  pkg-config,
  util-macros,
  wrapWithXFileSearchPathHook,
  xbitmaps,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bitmap";
  version = "1.1.2";

  src = fetchFromGitLab {
    owner = "app";
    repo = "bitmap";
    tag = "bitmap-${finalAttrs.version}";
    hash = "sha256-sQDt1zCxJ5kZ4kLVi1Wxrf7JiT721n2Sl6gNv3xZ0ts=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    util-macros
    autoreconfHook
    wrapWithXFileSearchPathHook
  ];

  buildInputs = [
    libx11
    libxaw
    xbitmaps
    libxmu
    xorgproto
    libxt
  ];

  installFlags = [ "appdefaultdir=$(out)/share/X11/app-defaults" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=bitmap-(.*)" ]; };

  meta = {
    description = "X bitmap (XBM) editor and converter utilities";
    homepage = "https://gitlab.freedesktop.org/xorg/app/bitmap";
    license = lib.licenses.mitOpenGroup;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bitmap";
  };
})
