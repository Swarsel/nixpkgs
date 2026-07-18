{
  lib,
  stdenv,
  fetchFromGitHub,
  cryptopp,
  curl,
  fontconfig,
  ghostscript,
  gradle_8,
  jre,
  libxml2,
  makeWrapper,
  meson,
  ninja,
  openssl,
  pcsclite,
  pkg-config,
  podofo0,
  stripJavaArchivesHook,
}:

let
  pname = "cie-middleware-linux";
  version = "1.5.9";

  src = fetchFromGitHub {
    owner = "M0rf30";
    repo = "cie-middleware-linux";
    tag = version;
    hash = "sha256-2UMKxanF35oBNBtIqfU46QUYJwXiTU1xCrCMqzqetgI=";
  };

  gradle = gradle_8;

  # Shared libraries needed by the Java application
  libraries = lib.makeLibraryPath [ ghostscript ];

in

stdenv.mkDerivation {
  inherit pname src version;

  postPatch = ''
    # substitute the cieid command with this $out/bin/cieid
    substituteInPlace libs/pkcs11/src/CSP/AbilitaCIE.cpp \
      --replace 'file = "cieid"' 'file = "'$out'/bin/cieid"'
  '';

  nativeBuildInputs = [
    makeWrapper
    stripJavaArchivesHook
    meson
    ninja
    pkg-config
    gradle
  ];

  buildInputs = [
    cryptopp
    fontconfig
    podofo0
    openssl
    pcsclite
    curl
    libxml2
  ];

  # Note: we use pushd/popd to juggle between the
  # libraries and the Java application builds.
  preConfigure = "pushd libs";

  buildPhase = ''
    runHook preBuild

    ninjaBuildPhase
    pushd ../..
    gradleBuildPhase
    popd

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    mesonCheckPhase
    pushd ../..
    gradleCheckPhase
    popd

    runHook postCheck
  '';

  postInstall = ''
    popd

    # Install the Java application
    ls cie-java/build/libs/CIEID-standalone.jar
    install -Dm755 cie-java/build/libs/CIEID-standalone.jar \
                   "$out/share/cieid/cieid.jar"

    # Create a wrapper
    mkdir -p "$out/bin"
    makeWrapper "${jre}/bin/java" "$out/bin/cieid" \
      --add-flags "-Djna.library.path='$out/lib:${libraries}'" \
      --add-flags "-Dawt.useSystemAAFontSettings=gasp" \
      --add-flags "-cp $out/share/cieid/cieid.jar" \
      --add-flags "app.m0rf30.cieid.MainApplication"

    # Install other files
    install -Dm644 data/app.m0rf30.cieid.desktop -t "$out/share/applications"
    install -Dm755 data/app.m0rf30.cieid.svg -t "$out/share/icons/hicolor/scalable/apps"
    install -Dm644 LICENSE "$out/share/licenses/cieid/LICENSE"
  '';

  gradleBuildTask = "standalone";

  gradleFlags = [
    "-Dorg.gradle.java.home=${jre}"
    "--build-file"
    "cie-java/build.gradle"
  ];

  hardeningDisable = [ "format" ];

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  preGradleUpdate = "cd ../..";

  meta = {
    description = "Middleware for the Italian Electronic Identity Card (CIE)";

    longDescription = ''
      Software for the usage of the Italian Electronic Identity Card (CIE).
      Access to PA services, signing and verification of documents

      Warning: this is an unofficial fork because the original software, as
      distributed by the Italian government, is essentially lacking a build
      system and is in violation of the license of the PoDoFo library.
    '';

    homepage = "https://github.com/M0Rf30/cie-middleware-linux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.unix;
  };
}
