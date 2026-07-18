{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libsm,
  libx11,
  libxaw,
  libxext,
  libxmu,
  libxt,
  pkg-config,
  util-macros,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xlogo";
  version = "1.0.7";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xlogo";
    tag = "xlogo-${finalAttrs.version}";
    hash = "sha256-KjJhuiFVn34vEZbC7ds4MrcXCHq9PcIpAuaCGBX/EXc=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  nativeBuildInputs = [
    util-macros
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libx11
    libxext
    libsm
    libxmu
    libxaw
    libxt
  ];

  configureFlags = [ "--with-appdefaultdir=$out/share/X11/app-defaults" ];

  meta = {
    description = "X Window System logo display demo";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xlogo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ raboof ];
    platforms = lib.platforms.unix;
    mainProgram = "xlogo";
  };
})
