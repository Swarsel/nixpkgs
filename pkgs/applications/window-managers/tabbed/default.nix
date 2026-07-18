{
  lib,
  stdenv,
  fetchgit,
  libx11,
  libxft,
  xorgproto,
  customConfig ? null,
  patches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "tabbed";
  version = "0.9";

  src = fetchgit {
    url = "https://git.suckless.org/tabbed";
    rev = finalAttrs.version;
    hash = "sha256-IpFbkyNNzMtESjpQNFOUdE6Tl+ezJN85T71Cm7bqljo=";
  };

  postPatch = lib.optionalString (customConfig != null) ''
    cp ${builtins.toFile "config.h" customConfig} ./config.h
  '';

  buildInputs = [
    xorgproto
    libx11
    libxft
  ];

  makeFlags = [ "CC:=$(CC)" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple generic tabbed fronted to xembed aware applications";
    homepage = "https://tools.suckless.org/tabbed";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
