{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  config,
  ladspaPlugins,
  librdf_raptor2,
  pkg-config,
  doCheck ? config.doCheckByDefault or false,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit doCheck;
  pname = "lrdf";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "swh";
    repo = "LRDF";
    rev = "v${finalAttrs.version}";
    sha256 = "00wzkfb8y0aqd519ypz067cq099dpc89w69zw8ln39vl6f9x2pd4";
  };

  postPatch = lib.optionalString doCheck ''
    sed -i -e 's:usr/local:${ladspaPlugins}:' examples/{instances,remove}_test.c
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [ librdf_raptor2 ];
  enableParallelBuilding = true;

  meta = {
    description = "Lightweight RDF library with special support for LADSPA plugins";
    homepage = "https://sourceforge.net/projects/lrdf/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
