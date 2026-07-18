{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libopenmpt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopenmpt-modplug";
  version = "0.8.9.0-openmpt1";

  src = fetchurl {
    url = "https://lib.openmpt.org/files/libopenmpt-modplug/libopenmpt-modplug-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-7M4aDuz9sLWCTKuJwnDc5ZWWKVosF8KwQyFez018T/c=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libopenmpt
  ];

  configureFlags = [
    "--enable-libmodplug"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Libmodplug emulation layer based on libopenmpt";
    homepage = "https://lib.openmpt.org/libopenmpt/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.unix;
  };
})
