{
  lib,
  copyDesktopItems,
  fetchzip,
  gdk-pixbuf,
  jdk17,
  makeDesktopItem,
  makeWrapper,
  shared-mime-info,
  stdenvNoCC,
  wrapGAppsHook3,
}:

stdenvNoCC.mkDerivation rec {
  pname = "uppaal";
  version = "5.0";

  src = fetchzip {
    url = "https://download.uppaal.org/uppaal-${version}/uppaal-${version}.${subversion}/uppaal-${version}.${subversion}-${platform}.zip";
    hash = "sha256-o71mP2/sDNRpmA1Qx59cvx6t4pk5pP0lrn1CogN3PuM=";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    jdk17
    gdk-pixbuf
    shared-mime-info
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/uppaal
    for size in 16 32 48 64 96 128; do
      install -Dm444 res/icon-"$size"x"$size".png "$out"/share/icons/hicolor/"$size"x"$size"/apps/uppaal.png
    done

    cp -r * $out/lib/uppaal

    chmod +x $out/lib/uppaal/uppaal

    makeWrapper $out/lib/uppaal/uppaal $out/bin/uppaal \
      --set JAVA_HOME ${jdk17} \
      --set PATH $out/lib/uppaal:$PATH \
      --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp" \
      --set _JAVA_AWT_WM_NONREPARENTING 1 # Java Swing renders a blank window on Wayland without this

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = "real-time modelling and verification tool";
      desktopName = "Uppaal";
      exec = "uppaal %U";
      genericName = "Uppaal";
      icon = "uppaal";
      name = "uppaal";
    })
  ];

  dontBuild = true;
  platform = "linux64";
  subversion = "0";

  meta = {
    description = "Integrated tool environment for modeling, validation and verification of real-time systems";
    homepage = "https://uppaal.org/";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ mortenmunk ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "uppaal";
    broken = !(stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64);
  };
}
