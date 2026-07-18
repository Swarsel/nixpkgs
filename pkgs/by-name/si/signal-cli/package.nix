{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  curl,
  dbus,
  dbus_java,
  gradle_9,
  libmatthew_java,
  makeWrapper,
  nix-update,
  openjdk25_headless,
  signal-cli,
  versionCheckHook,
  writeShellApplication,
}:

let
  gradle = gradle_9;
  libsignal-jni = callPackage ./libsignal-jni.nix { jdk = openjdk25_headless; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "signal-cli";
  version = "0.14.6";

  src = fetchFromGitHub {
    owner = "AsamK";
    repo = "signal-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VJ+/0CvfgtE6VHFeTLKAswTWrnyAL7AYrfCYVJpXDaE=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libmatthew_java
    dbus
    dbus_java
  ];

  # Tests require network access and a running signal server
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin

    cp build/install/signal-cli/lib/* $out/lib/
    cp ${libsignal-jni}/lib/* $out/lib/
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    makeWrapper ${openjdk25_headless}/bin/java $out/bin/signal-cli \
      --set JAVA_HOME "${openjdk25_headless}" \
      --add-flags "--enable-native-access=ALL-UNNAMED" \
      --add-flags "-classpath '$out/lib/*:${libmatthew_java}/lib/jni'" \
      --add-flags "-Djava.library.path=$out/lib:${libmatthew_java}/lib/jni:${dbus_java}/share/java/dbus" \
      --add-flags "org.asamk.signal.Main"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    makeWrapper ${openjdk25_headless}/bin/java $out/bin/signal-cli \
      --set JAVA_HOME "${openjdk25_headless}" \
      --add-flags "--enable-native-access=ALL-UNNAMED" \
      --add-flags "-classpath '$out/lib/*'" \
      --add-flags "-Djava.library.path=$out/lib" \
      --add-flags "org.asamk.signal.Main"
  ''
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "installDist";

  # Use the JDK for building
  gradleFlags = [
    "-Dfile.encoding=utf-8"
    "-Dorg.gradle.java.home=${openjdk25_headless}"
  ];

  mitmCache = gradle.fetchDeps {
    data = ./deps.json;
    pkg = signal-cli;
  };

  preGradleUpdate = ''
    gradle assemble
  '';

  passthru = {
    libsignal-jni = libsignal-jni;

    updateScript = lib.getExe (writeShellApplication {
      name = "signal-cli-update";

      runtimeInputs = [
        curl
        nix-update
      ];

      text = ''
        nix-update signal-cli
        nix-update signal-cli.passthru.libsignal-jni --version "$(curl --silent --location https://github.com/AsamK/signal-cli/raw/v"$(nix-instantiate --raw --eval -A signal-cli.version)"/libsignal-version)"
      '';
    });
  };

  meta = {
    description = "Command-line and dbus interface for communicating with the Signal messaging service";
    homepage = "https://github.com/AsamK/signal-cli";
    changelog = "https://github.com/AsamK/signal-cli/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = [
      lib.maintainers.klea
      lib.maintainers.akosseres
    ];

    platforms = lib.platforms.unix;
    mainProgram = "signal-cli";
  };
})
