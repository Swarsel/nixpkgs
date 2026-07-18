{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  jansson,
  libcap,
  ncurses,
  pkg-config,
  withGtk ? false,
}:

stdenv.mkDerivation rec {
  pname = "mtr${lib.optionalString withGtk "-gui"}";
  version = "0.96";

  src = fetchFromGitHub {
    owner = "traviscross";
    repo = "mtr";
    rev = "v${version}";
    sha256 = "sha256-Oit0jEm1g+jYCIoTak/mcdlF14GDkDOAWKmX2mYw30M=";
  };

  outputs = [
    "out"
    "man"
  ];

  # we need this before autoreconfHook does its thing
  postPatch = ''
    echo ${version} > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    ncurses
    jansson
  ]
  ++ lib.optional withGtk gtk3
  ++ lib.optional stdenv.hostPlatform.isLinux libcap;

  configureFlags = lib.optional (!withGtk) "--without-gtk";

  # and this after autoreconfHook has generated Makefile.in
  preConfigure = ''
    substituteInPlace Makefile.in \
      --replace ' install-exec-hook' ""
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Network diagnostics tool";
    homepage = "https://www.bitwizard.nl/mtr/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      koral
      raskin
      globin
      ryan4yin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mtr";
  };
}
