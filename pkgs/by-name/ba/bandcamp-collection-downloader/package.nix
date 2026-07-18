{
  lib,
  stdenv,
  fetchFromGitLab,
  gradle_8,
  jre,
  makeWrapper,
}:
let
  gradle = gradle_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bandcamp-collection-downloader";
  version = "0-unstable-2024-10-29";

  src = fetchFromGitLab {
    owner = "Ezwen";
    repo = "bandcamp-collection-downloader";
    rev = "fe8a98d92d776d194be196b6860f55e194a999f8";
    hash = "sha256-OaloKYlENq2kSzC8jvt4JJ7PsxLuqUuOdnYoazW5YUE=";
    domain = "framagit.org";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  # tests want to talk to bandcamp
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/bandcamp-collection-downloader
    cp build/libs/bandcamp-collection-downloader.jar $out/share/bandcamp-collection-downloader/bandcamp-collection-downloader.jar

    makeWrapper ${lib.getExe jre} $out/bin/bandcamp-collection-downloader \
      --add-flags "-jar $out/share/bandcamp-collection-downloader/bandcamp-collection-downloader.jar"

    runHook postInstall
  '';

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "fatjar";

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  meta = {
    description = "Tool to automatically download purchased music from bandcamp";
    homepage = "https://framagit.org/Ezwen/bandcamp-collection-downloader";
    license = lib.licenses.agpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];

    maintainers = [ lib.maintainers.shelvacu ];
    platforms = lib.platforms.all;
    mainProgram = "bandcamp-collection-downloader";
  };
})
