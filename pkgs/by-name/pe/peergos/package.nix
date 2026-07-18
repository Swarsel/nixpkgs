{
  lib,
  stdenv,
  fetchFromGitHub,
  ant,
  jdk25,
  jre,
  makeWrapper,
  nix-update-script,
  openjdk8-bootstrap,
  stripJavaArchivesHook,
}:

let
  tweetnacl = stdenv.mkDerivation {
    pname = "tweetnacl";
    version = "0-unstable-2025-11-06";

    src = fetchFromGitHub {
      owner = "ianopolous";
      repo = "tweetnacl-java";
      rev = "0cf99e1921b79eb91bc4c27cc15a27e325dbdb75";
      hash = "sha256-RyyC3/XhOhL7UxtPd2WODJgG6mPqkF/KDtvoa8PKWEM=";
    };

    postPatch = ''
      substituteInPlace Makefile \
        --replace-fail gcc cc
    '';

    nativeBuildInputs = [
      openjdk8-bootstrap # javah
    ];

    makeFlags = [ "jni" ];

    installPhase = ''
      install -Dvm644 libtweetnacl.so $out/lib/libtweetnacl.so
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "peergos";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "Peergos";
    repo = "web-ui";
    rev = "v${version}";
    hash = "sha256-WaTWz55pEfE/ncJnyc8FjkxJhsBYBXt7cFjBz8v0hw8=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace build.xml \
      --replace-fail '${"\${repository.version}"}' '${version}'
  '';

  nativeBuildInputs = [
    ant
    jdk25
    stripJavaArchivesHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    ant dist
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dvm644 server/Peergos.jar $out/share/java/peergos.jar
    install -Dvm644 ${tweetnacl}/lib/libtweetnacl.so $out/native-lib/libtweetnacl.so

    # --chdir as peergos expects to find `libtweetnacl.so` in `native-lib/`
    makeWrapper ${lib.getExe jre} $out/bin/peergos \
      --chdir $out \
      --add-flags "-Djava.library.path=native-lib -jar $out/share/java/peergos.jar"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "P2P, secure file storage, social network and application protocol";
    homepage = "https://peergos.org/";
    changelog = "https://github.com/Peergos/web-ui/releases/tag/v${version}";

    license = [
      lib.licenses.agpl3Only # server
      lib.licenses.gpl3Only # web-ui
    ];

    maintainers = with lib.maintainers; [
      raspher
      christoph-heiss
    ];

    platforms = lib.platforms.all;
    mainProgram = "peergos";
    downloadPage = "https://github.com/Peergos/web-ui";
  };
}
