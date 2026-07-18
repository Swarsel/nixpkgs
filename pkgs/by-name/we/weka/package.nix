{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  openjdk11,
  unzip,
  xdg-utils,
  maxMemoryAllocationPool ? "1000M",
}:

stdenv.mkDerivation rec {
  pname = "weka";
  version = "3.9.6";

  src = fetchurl {
    url = "mirror://sourceforge/weka/${lib.replaceStrings [ "." ] [ "-" ] "weka-${version}"}.zip";
    sha256 = "sha256-8fVN4MXYqXNEmyVtXh1IrauHTBZWgWG8AvsGI5Y9Aj0=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
    imagemagick
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  # The -Xmx1000M comes suggested from their download page:
  # https://www.cs.waikato.ac.nz/ml/weka/downloading.html
  installPhase = ''
    runHook preInstall

    mkdir -pv $out/share/weka
    mkdir -p $out/share/icons/hicolor
    cp -Rv * $out/share/weka

    makeWrapper ${openjdk11}/bin/java $out/bin/weka \
      --add-flags "-Xmx${maxMemoryAllocationPool} -jar $out/share/weka/weka.jar"

    makeWrapper ${openjdk11}/bin/java $out/bin/weka-java \
      --add-flags "-Xmx${maxMemoryAllocationPool} -cp $out/share/weka/weka.jar"

    ${lib.optionalString stdenv.hostPlatform.isLinux "
        makeWrapper ${xdg-utils}/bin/xdg-open $out/bin/weka-doc --add-flags $out/share/weka/documentation.html
    "}

    cat << EOF > $out/bin/weka-home
    #!${stdenv.shell}
    echo -n $out/share/weka
    EOF

    chmod ugo+x $out/bin/weka-home

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      mkdir -p $out/share/icons/hicolor/$size/apps
      magick convert $out/share/weka/weka.gif -resize $size $out/share/icons/hicolor/$size/apps/weka.png
    done;

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "ArtificialIntelligence"
        "ComputerScience"
      ];

      desktopName = "WEKA";
      exec = "weka";
      icon = "weka";
      name = "weka";
    })

    (makeDesktopItem {
      categories = [
        "Science"
        "ArtificialIntelligence"
        "ComputerScience"
      ];

      desktopName = "View the WEKA documentation with a web browser";
      exec = "weka-doc";
      icon = "weka";
      name = "weka-doc";
    })
  ];

  meta = {
    description = "Collection of machine learning algorithms for data mining tasks";
    homepage = "https://www.cs.waikato.ac.nz/ml/weka/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.mimame ];
    platforms = lib.platforms.unix;
    mainProgram = "weka";
  };
}
