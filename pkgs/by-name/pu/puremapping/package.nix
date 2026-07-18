{
  lib,
  stdenv,
  fetchurl,
  puredata,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "puremapping";
  version = "20160130";

  src = fetchurl {
    url = "https://www.chnry.net/data/puremapping-${finalAttrs.version}-generic.zip";
    sha256 = "1h7qgqd8srrxw2y1rkdw5js4k6f5vc8x6nlm2mq9mq9vjck7n1j7";
    name = "puremapping";
  };

  nativeBuildInputs = [ unzip ];
  buildInputs = [ puredata ];

  installPhase = ''
    mkdir -p $out/puremapping
    mv puremapping/ $out
  '';

  unpackPhase = ''
    unzip $src
  '';

  meta = {
    description = "Set of externals to facilitate the use of sensors within Pure Data and to create complex relations between input and output of a dynamic system";
    homepage = "http://www.chnry.net/ch/?090-Pure-Mapping&lang=en";
    license = lib.licenses.gpl1Only;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
