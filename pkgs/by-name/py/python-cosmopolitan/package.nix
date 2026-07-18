{
  lib,
  stdenv,
  bintools-unwrapped,
  cosmopolitan,
  unzip,
}:

stdenv.mkDerivation {
  pname = "python-cosmopolitan";
  version = "3.6.14";
  src = cosmopolitan.dist;

  nativeBuildInputs = [
    bintools-unwrapped
    unzip
  ];

  # slashes are significant because upstream uses o/$(MODE)/foo.o
  buildFlags = [ "o//third_party/python" ];
  doCheck = true;

  installPhase = ''
    runHook preInstall
    install o/third_party/python/*.com -Dt $out/bin
    runHook postInstall
  '';

  checkTarget = "o//third_party/python/test";
  dontConfigure = true;
  dontFixup = true;
  enableParallelBuilding = true;

  meta = {
    description = "Actually Portable Python using Cosmopolitan";
    homepage = "https://justine.lol/cosmopolitan/";
    license = lib.licenses.isc;
    platforms = lib.platforms.x86_64;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "python.com";
    teams = [ lib.teams.cosmopolitan ];
  };
}
