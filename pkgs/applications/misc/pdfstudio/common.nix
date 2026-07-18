{
  lib,
  stdenv,
  autoPatchelfHook,
  buildFHSEnv,
  copyDesktopItems,
  cups,
  desktopName,
  dpkg,
  jdk,
  longDescription,
  makeDesktopItem,
  pname,
  program,
  sane-backends,
  src,
  version,
  year,
  broken ? false,
  extraBuildInputs ? [ ],
}:
let
  thisPackage = stdenv.mkDerivation rec {
    inherit pname src version;

    postPatch = ''
      substituteInPlace opt/${program}${year}/${program}${year} --replace "# INSTALL4J_JAVA_HOME_OVERRIDE=" "INSTALL4J_JAVA_HOME_OVERRIDE=${jdk.out}"
      substituteInPlace opt/${program}${year}/updater --replace "# INSTALL4J_JAVA_HOME_OVERRIDE=" "INSTALL4J_JAVA_HOME_OVERRIDE=${jdk.out}"
    '';

    strictDeps = true;

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
      copyDesktopItems
    ];

    buildInputs = [
      sane-backends # for libsane.so.1
    ]
    ++ extraBuildInputs;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share/pixmaps}
      rm -rf opt/${program}${year}/jre
      cp -r opt/${program}${year} $out/share/
      ln -s $out/share/${program}${year}/.install4j/${program}${year}.png  $out/share/pixmaps/${pname}.png
      ln -s $out/share/${program}${year}/${program}${year} $out/bin/

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Office" ];
        comment = "Views and edits PDF files";
        desktopName = desktopName;
        exec = "${pname} %f";
        genericName = "View and edit PDF files";
        icon = "${pname}";
        mimeTypes = [ "application/pdf" ];
        name = "${pname}";
      })
    ];

    dontBuild = true;
  };

in
# Package with cups in FHS sandbox, because JAVA bin expects "/usr/bin/lpr" for printing.
buildFHSEnv {
  inherit pname version;

  # link desktop item and icon into FHS user environment
  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/pixmaps"
    ln -s ${thisPackage}/share/applications/*.desktop "$out/share/applications/"
    ln -s ${thisPackage}/share/pixmaps/*.png "$out/share/pixmaps/"
  '';

  runScript = "${program}${year}";

  targetPkgs = pkgs: [
    cups
    thisPackage
  ];

  meta = {
    inherit broken;
    description = "Easy to use, full-featured PDF editing software";
    longDescription = longDescription;
    homepage = "https://www.qoppa.com/${pname}/";
    license = lib.licenses.unfree;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ pwoelfel ];
    platforms = lib.platforms.linux;
    mainProgram = pname;
  };
}
