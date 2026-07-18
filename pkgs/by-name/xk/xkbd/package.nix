{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  freetype,
  libx11,
  libxext,
  libxft,
  libxi,
  libxpm,
  libxrender,
  libxtst,
  xinput,
  xorgproto,
}:

stdenv.mkDerivation rec {
  pname = "xkbd";
  version = "0.8.18";

  src = fetchFromGitHub {
    owner = "mahatma-kaganovich";
    repo = "xkbd";
    rev = "${pname}-${version}";
    sha256 = "05ry6q75jq545kf6p20nhfywaqf2wdkfiyp6iwdpv9jh238hf7m9";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    freetype
    libxrender
    libxft
    libxext
    libxtst
    libxpm
    libx11
    libxi
    xorgproto
    xinput
  ];

  meta = {
    description = "On-screen soft keyboard for X11";
    homepage = "https://github.com/mahatma-kaganovich/xkbd";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xkbd";
  };
}
