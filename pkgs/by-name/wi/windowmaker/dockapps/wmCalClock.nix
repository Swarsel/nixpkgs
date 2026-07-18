{
  lib,
  stdenv,
  dockapps-sources,
  libx11,
  libxext,
  libxpm,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (dockapps-sources) version src;
  pname = "wmCalClock";

  buildInputs = [
    libx11
    libxpm
    libxext
  ];

  preBuild = ''
    makeFlagsArray+=(
      CC="cc"
      INCDIR="-I${libx11.dev}/include -I${libxext.dev}/include -I${libxpm.dev}/include"
      LIBDIR="-I${libx11}/lib -I${libxext}/lib -I${libxpm}/lib"
    )
  '';

  preInstall = ''
    install -d ${placeholder "out"}/bin
    install -d ${placeholder "out"}/man/man1
  '';

  installFlags = [ "DESTDIR=${placeholder "out"}" ];
  sourceRoot = "${finalAttrs.src.name}/wmCalClock";

  meta = {
    description = "Calendar clock with antialiased text";
    homepage = "https://www.dockapps.net/wmcalclock";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
