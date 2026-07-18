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
  pname = "cputnik";

  buildInputs = [
    libx11
    libxpm
    libxext
  ];

  preBuild = ''
    makeFlagsArray+=(
      INCS="-I${libx11.dev}/include -I${libxext.dev}/include -I${libxpm.dev}/include"
      LIBS="-L${libx11}/lib -L${libxext}/lib -L${libxpm}/lib -lX11 -lXpm -lXext"
    )
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin/ cputnik

    runHook postInstall
  '';

  hardeningDisable = [ "format" ];
  sourceRoot = "${finalAttrs.src.name}/cputnik/src";

  meta = {
    description = "Calendar clock with antialiased text";
    homepage = "https://www.dockapps.net/wmcalclock";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
