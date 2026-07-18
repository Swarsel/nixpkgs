{
  lib,
  stdenv,
  fetchurl,
  fftwSinglePrec,
  puredata,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "timbreid";
  version = "0.7.0";

  src = fetchurl {
    url = "http://williambrent.conflations.com/pd/timbreID-${finalAttrs.version}-src.zip";
    sha256 = "14k2xk5zrzrw1zprdbwx45hrlc7ck8vq4drpd3l455i5r8yk4y6b";
  };

  nativeBuildInputs = [ unzip ];

  buildInputs = [
    puredata
    fftwSinglePrec
  ];

  makeFlags = [
    "tIDLib.o"
    "all"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/
    cp -r *.pd $out/
    cp -r *.pd_linux $out/
    cp -r audio/ $out/
    cp -r data/ $out/
    cp -r doc/ $out/
    runHook postInstall
  '';

  postFixup = ''
    mv $out/share/doc/ $out/
    rm -rf $out/share/
  '';

  enableParallelBuilding = true;
  sourceRoot = ".";

  meta = {
    description = "Collection of audio feature analysis externals for puredata";
    homepage = "http://williambrent.conflations.com/pages/research.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
