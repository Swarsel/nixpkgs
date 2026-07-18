{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  cvc5,
  gradle_8,
  jdk,
  jre,
  key,
  makeDesktopItem,
  makeWrapper,
  substitute,
  testers,
  z3,
}:

let
  gradle = gradle_8;

in
stdenv.mkDerivation rec {
  pname = "key";
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "KeYProject";
    repo = "key";
    tag = "KEY-${version}";
    hash = "sha256-1pN0lmr/teVitpMIM9M9lSTkmnVcZwdAQay2pzgJDCk=";
  };

  patches = [
    # Remove linting framework, causes issues with the update script.
    (substitute {
      src = ./remove-eisop-checker.patch;

      substitutions = [
        "--subst-var-by"
        "version"
        version
      ];
    })
  ];

  nativeBuildInputs = [
    jdk
    gradle
    makeWrapper
    copyDesktopItems
  ];

  # TODO: on update to 2.12.4+, try again
  # (currently some tests are failing)
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp key.ui/build/libs/key-*-exe.jar $out/share/java/KeY.jar
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp key.ui/src/main/resources/de/uka/ilkd/key/gui/images/key-color-icon-square.png $out/share/icons/hicolor/256x256/apps/key.png
    makeWrapper ${lib.getExe jre} $out/bin/KeY \
      --prefix PATH : ${
        lib.makeBinPath [
          z3
          cvc5
        ]
      } \
      --add-flags "-cp $out/share/java/KeY.jar de.uka.ilkd.key.core.Main"

    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Science" ];
      comment = meta.description;
      desktopName = "KeY";
      exec = meta.mainProgram;
      genericName = "KeY";
      icon = "key";
      name = "KeY";
    })
  ];

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  passthru.tests.version = testers.testVersion {
    command = "KeY --help";
    package = key;
  };

  meta = {
    description = "Java formal verification tool";

    longDescription = ''
      The KeY System is a formal software development tool that aims to
      integrate design, implementation, formal specification, and formal
      verification of object-oriented software as seamlessly as possible.
      At the core of the system is a novel theorem prover for the first-order
      Dynamic Logic for Java with a user-friendly graphical interface.
    '';

    homepage = "https://www.key-project.org"; # also https://formal.iti.kit.edu/key/
    changelog = "https://keyproject.github.io/key-docs/changelog/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      fgaz
      fliegendewurst
    ];

    platforms = jdk.meta.platforms;
    mainProgram = "KeY";
  };
}
