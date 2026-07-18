{
  lib,
  stdenv,
  autoPatchelfHook,
  cups,
  dpkg,
  fetchzip,
  libjpeg8,
  libusb1,
  makeWrapper,
  enablePtqpdf ? false, # Pantum's version of qpdf
}:

let
  architecture =
    {
      i686-linux = "i386";
      x86_64-linux = "amd64";
    }
    .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "pantum-driver";
  version = "1.1.167";

  src = fetchzip {
    url = "https://github.com/osguot/pantum-universal-driver/releases/download/release/Pantum.Linux.Driver.V${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }.zip";

    hash = "sha256-0RyCgU00ZwGwcUhCkod971noVB7G10xnbH64/AdIFMA=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    libusb1
    libjpeg8
    cups
  ];

  installPhase = ''
    dpkg-deb -x ./Resources/pantum_${version}-1_${architecture}.deb .

    mkdir -p $out $out/lib
    cp -r etc $out/
    cp -r usr/lib/cups $out/lib/
    cp -r usr/local/lib/* $out/lib/
    cp -r usr/share $out/
    cp Resources/locale/en_US.UTF-8/* $out/share/doc/pantum/
  ''
  + lib.optionalString enablePtqpdf ''
    cp -r opt/pantum/* $out/
    ln -s $out/lib/libqpdf.so* $out/lib/libqpdf.so
    ln -s $out/lib/libqpdf.so $out/lib/libqpdf.so.21
  '';

  meta = {
    description = "Pantum universal driver";
    homepage = "https://global.pantum.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ deinferno ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
