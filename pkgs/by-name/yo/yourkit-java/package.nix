{
  lib,
  copyDesktopItems,
  fetchzip,
  imagemagick,
  jdk21,
  makeDesktopItem,
  stdenvNoCC,
}:
let
  jre = jdk21;

  vPath = v: lib.elemAt (lib.splitString "-" v) 0;

  version = "2025.9-b175";

  arches = {
    aarch64-linux = "arm64";
    x86_64-linux = "x64";
  };

  arch = arches.${stdenvNoCC.targetPlatform.system} or (throw "Unsupported system");

  hashes = {
    arm64 = "sha256-pVgXlyKb3E6twBGnQJeMDR/7RxX7iyxeVaTAbbWtb7c=";
    x64 = "sha256-srNckPBzl8GjFIlvDwZb6VBhqnVHF+oMnsZcV9Rh76Q=";
  };

  desktopItem = makeDesktopItem {
    categories = [
      "Development"
      "Java"
      "Profiling"
    ];

    desktopName = "YourKit Java Profiler " + version;
    exec = "yourkit-java-profiler %f";
    icon = "yourkit-java-profiler";
    name = "YourKit Java Profiler";
    startupWMClass = "YourKit Java Profiler";
    terminal = false;
    type = "Application";
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "yourkit-java";

  src = fetchzip {
    url = "https://download.yourkit.com/yjp/${vPath version}/YourKit-JavaProfiler-${version}-${arch}.zip";
    hash = hashes.${arch};
  };

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -pr bin lib license.html license-redist.txt probes samples $out
    cp ${./forbid-desktop-item-creation} $out/bin/forbid-desktop-item-creation
    mv $out/bin/profiler.sh $out/bin/yourkit-java-profiler
    mkdir -p $out/share/icons
    convert $out/bin/profiler.ico\[0] \
            -size 256x256 \
            $out/share/icons/yourkit-java-profiler.png
    rm $out/bin/profiler.ico
    rm -rf $out/bin/{windows-*,mac,linux-{*-32,musl-*,ppc-*}}
    if [[ ${arch} = x64 ]]; then
      rm -rf $out/bin/linux-arm-64
    else
      rm -rf $out/bin/linux-x86-64
    fi
    substituteInPlace $out/bin/yourkit-java-profiler \
        --replace 'JAVA_EXE="$YD/jre64/bin/java"' JAVA_EXE=${jre}/bin/java
    # Use our desktop item, which will be purged when this package
    # gets removed
    sed -i -e "/^YD=/isource $out/bin/forbid-desktop-item-creation\\
        " \
        $out/bin/yourkit-java-profiler

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Award winning, fully featured low overhead profiler for Java EE and Java SE platforms";
    homepage = "https://www.yourkit.com";
    changelog = "https://www.yourkit.com/changes/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ herberteuler ];
    platforms = lib.attrNames arches;
    mainProgram = "yourkit-java-profiler";
  };
}
