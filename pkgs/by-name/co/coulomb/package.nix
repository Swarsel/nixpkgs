{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  gradle,
  gtk4,
  jdk21_headless,
  libadwaita,
  librsvg,
  makeWrapper,
  nix-update-script,
  pango,
  pkg-config,
  stripJavaArchivesHook,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coulomb";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "hamza-algohary";
    repo = "Coulomb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SbtFUUla0uoeDik+7CtibV/lvgUg8N81WWRp2+8wygM=";
  };

  postPatch = ''
    substituteInPlace app/build.gradle.kts \
      --replace-fail "languageVersion.set(JavaLanguageVersion.of(19))" "languageVersion.set(JavaLanguageVersion.of(21))"
  '';

  nativeBuildInputs = [
    gradle
    jdk21_headless
    makeWrapper
    pkg-config
    stripJavaArchivesHook
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    pango
    gdk-pixbuf
    atk
    cairo
    adwaita-icon-theme
    librsvg
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/coulomb,lib-jna}
    cp app/build/libs/app-all.jar $out/share/coulomb/

    mkdir -p $out/share/{applications,icons/{dark,light,hicolor/scalable/apps}}
    cp app/build/resources/main/*.desktop $out/share/applications
    cp -r app/build/resources/main/icons/vector/* $out/share/icons/
    cp app/build/resources/main/icons/vector/light/coulomb.svg $out/share/icons/hicolor/scalable/apps/io.github.hamza_algohary.Coulomb.svg

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${jdk21_headless}/bin/java $out/bin/coulomb \
    --add-flags "-Djava.library.path=${lib.makeLibraryPath finalAttrs.buildInputs}" \
    --add-flags "-jar $out/share/coulomb/app-all.jar" \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
    ''${gappsWrapperArgs[@]}
  '';

  dontWrapGApps = true;
  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple and beautiful circuit simulator app";
    homepage = "https://github.com/hamza-algohary/Coulomb";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thtrf
      _0xSA7
    ];

    platforms = lib.platforms.linux;
    mainProgram = "coulomb";
  };
})
