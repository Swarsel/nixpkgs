{
  lib,
  stdenv,
  autoreconfHook,
  fetchgit,
  libosmo-netif,
  libosmocore,
  lksctp-tools,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libosmo-sigtran";
  version = "2.2.1";

  # fetchFromGitea hangs
  src = fetchgit {
    url = "https://gitea.osmocom.org/osmocom/libosmo-sigtran.git";
    rev = finalAttrs.version;
    hash = "sha256-EBBSoSX5tImTLRP7Klhjj/YM8+4RyyJClymIXQK8DgE=";
  };

  postPatch = ''
    echo "${finalAttrs.version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    lksctp-tools
    libosmocore
    libosmo-netif
  ];

  configureFlags = [ "--with-systemdsystemunitdir=$out" ];
  enableParallelBuilding = true;

  meta = {
    description = "SCCP + SIGTRAN (SUA/M3UA) libraries as well as OsmoSTP";
    homepage = "https://osmocom.org/projects/libosmo-sccp";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      markuskowa
    ];

    platforms = lib.platforms.linux;
    mainProgram = "osmo-stp";
  };
})
