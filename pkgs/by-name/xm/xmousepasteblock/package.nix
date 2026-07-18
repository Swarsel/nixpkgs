{
  lib,
  stdenv,
  fetchFromGitHub,
  libev,
  libx11,
  libxext,
  libxi,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmousepasteblock";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "milaq";
    repo = "XMousePasteBlock";
    rev = finalAttrs.version;
    hash = "sha256-uHlHGVnIro6X4kRp79ibtqMmiv2XQT+zgbQagUxdB0c=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxext
    libxi
    libev
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  meta = {
    description = "Middle mouse button primary X selection/clipboard paste disabler";
    homepage = "https://github.com/milaq/XMousePasteBlock";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "xmousepasteblock";
  };
})
