{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  libxcb,
  libxcb-util,
  libxcb-wm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xtitle";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "baskerville";
    repo = "xtitle";
    rev = finalAttrs.version;
    hash = "sha256-SVfM2vCCacgchXj0c0sPk3VR6DUI4R0ofFnxJSY4oDg=";
  };

  postPatch = ''
    sed -i "s|/usr/local|$out|" Makefile
  '';

  buildInputs = [
    libxcb
    git
    libxcb-util
    libxcb-wm
  ];

  meta = {
    description = "Outputs X window titles";
    homepage = "https://github.com/baskerville/xtitle";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ meisternu ];
    platforms = lib.platforms.linux;
    mainProgram = "xtitle";
  };
})
