{
  lib,
  stdenv,
  fetchurl,
  fixDarwinDylibNames,
  unzip,
}:

let
  versionMajor = "1";
  versionMinor = "0.6";
  version = versionMajor + "." + versionMinor;
  removeDots = lib.replaceStrings [ "." ] [ "" ];
  src-doc = fetchurl {
    sha256 = "1kyda09i9p89xfq90ninwi7w13k1w3ljpl4gqdhpfhi5g8fgxx7f";
    url = "http://www.inchi-trust.org/download/${removeDots version}/INCHI-1-DOC.zip";
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "inchi";

  src = fetchurl {
    url = "http://www.inchi-trust.org/download/${removeDots version}/INCHI-1-SRC.zip";
    sha256 = "1zbygqn0443p0gxwr4kx3m1bkqaj8x9hrpch3s41py7jq08f6x28";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ unzip ] ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  preConfigure = ''
    cd ./INCHI_API/libinchi/gcc
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace makefile \
      --replace ",--version-script=libinchi.map" "" \
      --replace "LINUX_Z_RELRO = ,-z,relro" "" \
      --replace "-soname" "-install_name" \
      --replace "gcc" $CC
  '';

  installPhase =
    let
      versionOneDot = versionMajor + "." + removeDots versionMinor;
    in
    ''
      runHook preInstall

      cd ../../..
      mkdir -p $out/lib
      mkdir -p $out/include/inchi
      mkdir -p $doc/share/

      install -m 755 INCHI_API/bin/Linux/libinchi.so.${versionOneDot}.00 $out/lib
      ln -s $out/lib/libinchi.so.${versionOneDot}.00 $out/lib/libinchi.so.1
      ln -s $out/lib/libinchi.so.${versionOneDot}.00 $out/lib/libinchi.so
      install -m 644 INCHI_BASE/src/*.h $out/include/inchi

      runHook postInstall
    '';

  postInstall = ''
    unzip '${src-doc}'
    install -m 644 INCHI-1-DOC/*.pdf $doc/share
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    fixDarwinDylibNames $(find "$out" -name "*.so.*")
  '';

  enableParallelBuilding = true;

  meta = {
    description = "IUPAC International Chemical Identifier library";
    homepage = "https://www.inchi-trust.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ rmcgibbo ];
  };
}
