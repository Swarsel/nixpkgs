{
  lib,
  stdenv,
  fetchurl,
  gmp,
  librdf_raptor2,
  librdf_rasqal,
  pkg-config,
  redland,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "redstore";
  version = "0.5.4";

  src = fetchurl {
    url = "https://www.aelius.com/njh/redstore/redstore-${finalAttrs.version}.tar.gz";
    hash = "sha256-WL1l/aOIq0Aeatw2ctepxRHkOdlHdPzFoe9tt5x0gUE=";
  };

  # source code tries to use `true` as a variable
  # despite it being a reserved keyword
  postPatch = ''
    substituteInPlace ./src/redhttp/server.c --replace-fail \
      'true' 'opt'
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gmp
    redland
    zlib
    librdf_raptor2
    librdf_rasqal
  ];

  preConfigure = ''
    # Define _XOPEN_SOURCE to enable, e.g., getaddrinfo.
    configureFlagsArray+=(
      "CFLAGS=-D_XOPEN_SOURCE=600 -I${librdf_raptor2}/include/raptor2 -I${librdf_rasqal}/include/rasqal"
    )
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  meta = {
    description = "HTTP interface to Redland RDF store";
    homepage = "https://www.aelius.com/njh/redstore/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = with lib.platforms; linux ++ freebsd ++ gnu;
    mainProgram = "redstore";
  };
})
