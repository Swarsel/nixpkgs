{
  lib,
  fetchurl,
  jdk25_headless,
  libwebp, # Fixes https://github.com/gotson/komga/issues/1294
  makeWrapper,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "komga";
  version = "1.25.0";

  src = fetchurl {
    url = "https://github.com/gotson/${pname}/releases/download/${version}/${pname}-${version}.jar";
    sha256 = "sha256-NlL5rBpCFbiZ+HHNoOgLE0Ht3lXXul2qIb8rq9qEzhM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildCommand = ''
    makeWrapper ${jdk25_headless}/bin/java $out/bin/komga --add-flags "-jar $src" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libwebp ]}
  '';

  passthru.tests = {
    komga = nixosTests.komga;
  };

  meta = {
    description = "Free and open source comics/mangas server";
    homepage = "https://komga.org/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      tebriel
      govanify
    ];

    platforms = jdk25_headless.meta.platforms;
    mainProgram = "komga";
  };
}
