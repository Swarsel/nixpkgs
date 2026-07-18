{
  lib,
  buildPackages,
  fetchzip,
  jdk_headless,
  makeWrapper,
  stdenvNoCC,
  javaOpts ? "-XX:+UseZGC",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hentai-at-home";
  version = "1.6.5";

  src = fetchzip {
    url = "https://repo.e-hentai.org/hath/HentaiAtHome_${finalAttrs.version}_src.zip";
    hash = "sha512-oKyvzHZTPwSTcjsNOQ0LIl6rV+b7JDnuWbYKFogWWkyKcR/xDcNPNhUrKv8QLH6a1AQ2T8DYkxcJYnjhgsaovA==";
    stripRoot = false;
  };

  strictDeps = true;

  nativeBuildInputs = [
    jdk_headless
    makeWrapper
  ];

  makeFlags = [ "all" ];

  env = {
    LANG = "en_US.UTF-8";
  }
  // lib.optionalAttrs (stdenvNoCC.buildPlatform.libc == "glibc") {
    LOCALE_ARCHIVE = "${buildPackages.glibcLocales}/lib/locale/locale-archive";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp build/HentaiAtHome.jar $out/share/java

    mkdir -p $out/bin
    makeWrapper ${jdk_headless}/bin/java $out/bin/HentaiAtHome \
      --add-flags "${javaOpts} -jar $out/share/java/HentaiAtHome.jar"

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    pushd $(mktemp -d)
    $out/bin/HentaiAtHome
    popd

    runHook postInstallCheck
  '';

  enableParallelBuilding = false;

  meta = {
    description = "Open-source P2P gallery distribution system which reduces the load on the E-Hentai Galleries";
    homepage = "https://ehwiki.org/wiki/Hentai@Home";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ terrorjack ];
    platforms = jdk_headless.meta.platforms;
    mainProgram = "HentaiAtHome";
  };
})
