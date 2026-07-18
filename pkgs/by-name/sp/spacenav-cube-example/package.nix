{
  lib,
  stdenv,
  libspnav,
  libx11,
  mesa_glu,
}:

stdenv.mkDerivation {
  inherit (libspnav) version src;
  pname = "spacenav-cube-example";

  buildInputs = [
    libx11
    mesa_glu
    libspnav
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp cube $out/bin/spacenav-cube-example
    runHook postInstall
  '';

  sourceRoot = "${libspnav.src.name}/examples/cube";

  meta = {
    description = "Example application to test the spacenavd driver";
    homepage = "https://spacenav.sourceforge.net/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sohalt ];
    platforms = lib.platforms.unix;
    mainProgram = "spacenav-cube-example";
  };
}
