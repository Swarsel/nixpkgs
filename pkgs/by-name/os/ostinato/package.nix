{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  copyDesktopItems,
  diffutils,
  gawk,
  gzip,
  libnl,
  libpcap,
  makeDesktopItem,
  protobuf_21,
  qt5,
  wireshark,
}:
let
  protobuf = protobuf_21;

  ostinatoIcon = fetchurl {
    hash = "sha256-9cBngj8pNOTTWNdvZaND79aa14OnrqvXq0zjzQNJDXA=";
    url = "https://ostinato.org/images/site-logo.png";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ostinato";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "pstavirs";
    repo = "ostinato";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/fPUxGeh5Cc3rb+1mR0chkiFPw5m+O6KtWDvzLn0iYo=";
  };

  patches = [ ./drone_ini.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    qt5.qmake
    qt5.wrapQtAppsHook
    qt5.qtscript
    protobuf
  ];

  buildInputs = [
    qt5.qtbase
    protobuf
    libpcap
    qt5.qtscript
    libnl
  ];

  preFixup = ''
    substituteInPlace $out/share/applications/ostinato.desktop \
      --subst-var out

    cat > $out/bin/ostinato.ini <<EOF
    WiresharkPath=${wireshark}/bin/wireshark
    TsharkPath=${wireshark}/bin/tshark
    GzipPath=${gzip}/bin/gzip
    DiffPath=${diffutils}/bin/diff
    AwkPath=${gawk}/bin/awk
    EOF
  '';

  __structuredAttrs = true;

  desktopItems = lib.singleton (makeDesktopItem {
    categories = [ "Network" ];
    comment = "Network packet and traffic generator and analyzer with a friendly GUI";
    desktopName = "Ostinato";
    exec = "@out@/bin/ostinato";

    extraConfig = {
      "Comment[it]" = "Generatore ed Analizzatore di pacchetti di rete con interfaccia amichevole";
      "GenericName[it]" = "Generatore ed Analizzatore di pacchetti di rete";
    };

    genericName = "Packet/Traffic Generator and Analyzer";
    icon = ostinatoIcon;
    name = "ostinato";
    startupNotify = true;
  });

  # `cd common; qmake ostproto.pro; make pdmlreader.o`:
  # pdmlprotocol.h:23:25: fatal error: protocol.pb.h: No such file or directory
  enableParallelBuilding = false;

  prePatch = ''
    sed -i 's|/usr/include/libnl3|${libnl.dev}/include/libnl3|' server/drone.pro
  '';

  meta = {
    description = "Packet traffic generator and analyzer";
    homepage = "https://ostinato.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rick68 ];
    platforms = with lib.platforms; linux ++ darwin ++ cygwin;
  };
})
