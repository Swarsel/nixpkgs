{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitea,
  geos,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librttopo";
  version = "1.1.0";

  src = fetchFromGitea {
    owner = "rttopo";
    repo = "librttopo";
    rev = "librttopo-${finalAttrs.version}";
    hash = "sha256-VxyQr4nBy4PS2IjabBZHvzejFPDNBgSNn528ZCf99EA=";
    domain = "git.osgeo.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    validatePkgConfig
  ];

  buildInputs = [ geos ];

  configureFlags = [
    "--with-geosconfig=${lib.getExe' (lib.getDev geos) "geos-config"}"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "RT Topology Library";
    homepage = "https://git.osgeo.org/rttopo/librttopo";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.geospatial ];
  };
})
