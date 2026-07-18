{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  e2fsprogs,
  gmp,
  gtk3,
  libGL,
  libgcrypt,
  libx11,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "banana-accounting";
  version = "10.1.24";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    e2fsprogs
    gmp
    gtk3
    (lib.getLib stdenv.cc.cc)
    libGL
    libx11
    libgcrypt
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share
    cp -r . $out/opt/banana-accounting
    ln -s $out/opt/banana-accounting/usr/bin/bananaplus $out/bin/bananaplus
    ln -s $out/opt/banana-accounting/usr/share/applications $out/share/applications
    ln -s $out/opt/banana-accounting/usr/share/icons $out/share/icons

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  srcs = fetchurl {
    hash = "sha256-5GewPGOCyeS6faL8aMUZ/JDUUn2PGuur0ws/7nlNX6M=";
    url = "https://web.archive.org/web/20250416013207/https://www.banana.ch/accounting/files/bananaplus/exe/bananaplus.tgz";
  };

  meta = {
    description = "Accounting Software for small companies, associations and individuals";
    homepage = "https://www.banana.ch";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ jacg ];
    platforms = [ "x86_64-linux" ];
  };
})
