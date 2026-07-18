{
  lib,
  fetchFromGitHub,
  # native
  copyDesktopItems,
  gettext,
  glib,
  gtk3,
  libGL,
  libxtst,
  libxxf86vm,
  makeDesktopItem,
  maven,
  temurin-bin-21,
  temurin-jre-bin-21,
  wrapGAppsHook3,
}:

let
  mavenOurJdk = maven.override {
    jdk_headless = temurin-jre-bin-21;
  };
in
mavenOurJdk.buildMavenPackage rec {
  pname = "pdfsam-basic";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "torakiki";
    repo = "pdfsam";
    rev = "v${version}";
    hash = "sha256-9IzYnWYE0OD1b4xybl3NdaBvVSw6C4+1ORUnrotqSuc=";
  };

  nativeBuildInputs = [
    # Used as the main java implementation. Also the build relies upon jlink
    # which is included in this package.
    temurin-bin-21
    gettext
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    glib
    libxxf86vm
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0644 pdfsam-basic/src/deb/icon.svg $out/share/icons/pdfsam-basic.svg
    mkdir $out/lib
    tar -xf pdfsam-basic/target/pdfsam-basic-${version}-linux-x64.tar.gz -C $out/lib
    mv $out/lib/pdfsam-basic-${version}-linux-x64 $out/lib/pdfsam-basic
    # Based upon upstream's default $out/lib/pdfsam-basic/bin/pdfsam.sh file,
    # but with Nix specific dynamically loaded libraries
    makeWrapper ${temurin-jre-bin-21}/bin/java $out/bin/pdfsam-basic \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libxxf86vm
          libxtst
          gtk3
          libGL
        ]
      }" \
      --argv0 pdfsam-basic \
      --add-flags --enable-preview \
      --add-flags "--module-path $out/lib/pdfsam-basic/lib" \
      --add-flags "--module org.pdfsam.basic/org.pdfsam.basic.App" \
      --add-flags "-Xmx512M" \
      --add-flags "-Dprism.lcdtext=false" \
      --add-flags "-splash:$out/lib/pdfsam-basic/splash.png" \
      --add-flags "-Dapp.name=pdfsam-basic" \
      --add-flags "-Dapp.home=$out/lib/pdfsam-basic" \
      --add-flags "-Dbasedir=$out/lib/pdfsam-basic"
    # Remove bundled executables, shared objects etc, that are not needed on
    # Nix (we just need the jar files).
    rm -r $out/lib/pdfsam-basic/{doc,bin,runtime}

    runHook postInstall
  '';

  # Based on upstream's desktop file:
  # https://github.com/torakiki/pdfsam/blob/master/pdfsam-basic/src/deb/pdfsam-basic.desktop
  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = meta.description;
      desktopName = "PDFsam Basic";
      exec = "pdfsam-basic";
      genericName = "PDF Split and Merge";
      icon = "pdfsam-basic";
      mimeTypes = [ "application/pdf" ];
      name = "PDFsam Basic";
    })
  ];

  mvnHash = "sha256-Y/wz/XuzDpT7qnk/pRBkv6PeI0GmqKXh54gqb7cWHHw=";
  mvnParameters = "-Drelease -Dmaven.test.skip";

  meta = {
    description = "Multi-platform software designed to extract pages, split, merge, mix and rotate PDF files";
    homepage = "https://github.com/torakiki/pdfsam";
    license = lib.licenses.agpl3Plus;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      doronbehar
      _1000101
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "pdfsam-basic";
  };
}
