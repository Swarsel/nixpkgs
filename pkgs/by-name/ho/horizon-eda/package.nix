{
  stdenv,
  boost,
  callPackage,
  coreutils,
  libspnav,
  python3,
  wrapGAppsHook3,
}:

let
  base = callPackage ./base.nix { };
in
stdenv.mkDerivation {
  inherit (base)
    pname
    version
    src
    meta
    env
    ;

  nativeBuildInputs = base.nativeBuildInputs ++ [
    boost.dev
    wrapGAppsHook3
    python3
  ];

  buildInputs = base.buildInputs ++ [
    libspnav
  ];

  enableParallelBuilding = true;

  installFlags = [
    "INSTALL=${coreutils}/bin/install"
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  # provide base for python module
  passthru = {
    inherit base;
  };
}
