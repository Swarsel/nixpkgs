{
  lib,
  stdenv,
  copyDesktopItems,
  desktopToDarwinBundle,
  fetchzip,
  imagemagick,
  jre,
  makeDesktopItem,
  makeWrapper,
  perl,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastqc";
  version = "0.12.1";

  src = fetchzip {
    url = "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${finalAttrs.version}.zip";
    hash = "sha256-TenRG2x8ivJ2HM2ZpLaJShp0yI0Qc6K5lW5/NJFAa1I";
  };

  nativeBuildInputs = [
    makeWrapper
    imagemagick
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems # postInstallHook
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle; # fixupOutputHook

  buildInputs = [
    jre
    perl
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,FastQC}
    cp -r $src/* $out/FastQC

    # Create desktop item
    mkdir -p $out/share/{applications,icons}
    # Freedesktop doesn't support windows ICO files. Use imagemagick to convert it to PNG
    convert $out/FastQC/fastqc_icon.ico $out/share/icons/fastqc.png

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper $out/FastQC/fastqc $out/bin/fastqc --prefix PATH : ${jre}/bin
  '';

  desktopItem = (
    makeDesktopItem {
      categories = [ "Science" ];
      comment = finalAttrs.meta.description;
      desktopName = "FastQC";
      exec = "fastqc";
      icon = "fastqc";
      name = "FastQC";
    }
  );

  desktopItems = [ finalAttrs.desktopItem ];
  dontBuild = true;

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Quality control application for high throughput sequence data";

    longDescription = ''
      FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis.

      The main functions of FastQC are

      - Import of data from BAM, SAM or FastQ files (any variant)
      - Providing a quick overview to tell you in which areas there may be problems
      - Summary graphs and tables to quickly assess your data
      - Export of results to an HTML based permanent report
      - Offline operation to allow automated generation of reports without running the interactive application
    '';

    homepage = "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/";

    license = with lib.licenses; [
      gpl3Plus
      asl20
    ];

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.dflores ];
    platforms = lib.platforms.unix;
    mainProgram = "fastqc";
  };
})
