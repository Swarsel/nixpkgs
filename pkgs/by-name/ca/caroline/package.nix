{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gtk3,
  libgee,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "caroline";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "dcharles525";
    repo = "caroline";
    tag = finalAttrs.version;
    hash = "sha256-v423h9EC/h6B9VABhkvmYcyYXKPpvqhI8O7ZjbO637k";
  };

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
    libgee
    gtk3
  ];

  meta = {
    description = "Simple Cairo Chart Library for GTK and Vala";
    homepage = "https://github.com/dcharles525/Caroline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ grindhold ];
    platforms = lib.platforms.unix;
  };
})
