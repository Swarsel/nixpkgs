{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmicrodns";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "videolabs";
    repo = "libmicrodns";
    rev = finalAttrs.version;
    sha256 = "05vgka45c1frnv4q7pbz0bggsn5xaykh4xpklh9yb6d6qj7dbx0b";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = {
    description = "Minimal mDNS resolver library, used by VLC";
    homepage = "https://github.com/videolabs/libmicrodns";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.shazow ];
    platforms = lib.platforms.unix;
  };
})
