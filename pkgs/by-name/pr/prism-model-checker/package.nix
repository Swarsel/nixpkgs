{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  copyDesktopItems,
  coreutils,
  gccStdenv,
  jre,
  makeDesktopItem,
  makeWrapper,
  openjdk,
}:

let
  stdenv' = if stdenv.hostPlatform.isDarwin then gccStdenv else stdenv;
in
stdenv'.mkDerivation (finalAttrs: {
  pname = "prism-model-checker";
  version = "4.9";

  src = fetchFromGitHub {
    owner = "prismmodelchecker";
    repo = "prism";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eoyMGrXta49j2h/bStPuzrF6OZd/l2aQBngPbTZEvAo=";
  };

  postPatch = ''
    substituteInPlace prism/install.sh --replace-fail "/bin/mv" "mv"
  '';

  nativeBuildInputs = [
    openjdk
    copyDesktopItems
    makeWrapper
  ]
  ++ lib.optionals stdenv'.hostPlatform.isDarwin [ cctools ];

  makeFlags = [
    "JAVA_DIR=${openjdk}"
    "release_config"
    "clean_all"
    "all"
    "binary"
  ];

  preBuild = ''
    cd prism
  '';

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/share/
    cp -r bin/ $out/
    cp -r lib/ $out/
    cp -r etc/{scripts,syntax-highlighters,prism{.css,.tex,-eclipse-formatter.xml}} -t $out/share
    for size in 16 24 32 48 64 128 256; do
        mkdir --parents $out/share/icons/hicolor/''${size}x''${size}/apps
        cp etc/icons/p''${size}.png $out/share/icons/hicolor/''${size}x''${size}/apps/prism-model-checker.png
    done

    mv install.sh $out/
    cd $out
    ./install.sh
    rm install.sh

    for f in $out/bin/*; do
      wrapProgram $f \
          --set JAVA_HOME ${jre.home} \
          --set PRISM_JAVA ${lib.getExe jre} \
          --prefix PATH: ${lib.makeBinPath [ jre ]}
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "Math"
      ];

      comment = "Probabalistic Symbolic Model Checker";
      desktopName = "XPrism";
      exec = "xprism";
      icon = "prism-model-checker";
      name = "prism-model-checker-xprism";
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "Probabalistic Symbolic Model Checker";
    homepage = "https://www.prismmodelchecker.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.astrobeastie ];
    platforms = lib.platforms.unix;
    mainProgram = "prism";
  };
})
