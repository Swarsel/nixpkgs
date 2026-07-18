{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeDesktopItem,
  makeWrapper,
  pcsclite,
}:

let
  version = "1.2.4";
  srcs = {
    cifs = fetchurl {
      sha256 = "0rc862lx3y6sw87r1v5xjmqqpysyr1x6yqhycqmcdrwz0j3wykrr";
      url = "https://jnlp.openecard.org/cifs-${version}-20171212-0958.jar";
    };

    logo = fetchurl {
      sha256 = "0rpmyv10vjx2yfpm03mqliygcww8af2wnrnrppmsazdplksaxkhs";
      url = "https://raw.githubusercontent.com/ecsec/open-ecard/1.2.3/gui/graphics/src/main/ext/oec_logo_bg-transparent.svg";
    };

    richclient = fetchurl {
      sha256 = "1ckhyhszp4zhfb5mn67lz603b55z814jh0sz0q5hriqzx017j7nr";
      url = "https://jnlp.openecard.org/richclient-${version}-20171212-0958.jar";
    };
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "open-ecard";
  src = srcs.richclient;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java
    cp ${srcs.richclient} $out/share/java/richclient-${version}.jar
    cp ${srcs.cifs} $out/share/java/cifs-${version}.jar

    mkdir -p $out/share/applications $out/share/pixmaps
    cp $desktopItem/share/applications/* $out/share/applications
    cp ${srcs.logo} $out/share/pixmaps/oec_logo_bg-transparent.svg

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-cp $out/share/java/cifs-${version}.jar" \
      --add-flags "-jar $out/share/java/richclient-${version}.jar" \
      --suffix LD_LIBRARY_PATH ':' ${lib.getLib pcsclite}/lib
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Utility"
      "Security"
    ];

    comment = "Client side implementation of the eCard-API-Framework";
    desktopName = "Open eCard App";
    exec = pname;
    genericName = "eCard App";
    icon = "oec_logo_bg-transparent.svg";
    name = pname;
  };

  dontUnpack = true;

  meta = {
    description = "Client side implementation of the eCard-API-Framework (BSI
      TR-03112) and related international standards, such as ISO/IEC 24727";

    homepage = "https://www.openecard.org/";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ sephalon ];
    platforms = lib.platforms.linux;
    mainProgram = "open-ecard";
  };
}
