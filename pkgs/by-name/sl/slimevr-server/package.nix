{
  lib,
  stdenv,
  gradle,
  hidapi,
  jdk17,
  makeWrapper,
  replaceVars,
  runCommand,
  slimevr,
}:
let
  # JDK can't be headless while SlimeVR uses JavaOSC 0.8.
  java = jdk17;
  # Without this the hidapi bundled with `org.hid4java:hid4java` will be used.
  # The bundled version won't be able to find `libudev.so.1`.
  javaOptions =
    let
      # hid4java tries to load `libhidapi.so` which doesn't exist in Nix's hidapi.
      # The `libhidapi.so` it expects is actually `libhidapi-hidraw.so`.
      libhidapi = runCommand "libhidapi" { } ''
        mkdir -p $out/lib
        ln -s ${hidapi}/lib/libhidapi-hidraw.so $out/lib/libhidapi.so
      '';
    in
    "-Djna.library.path='${
      lib.makeLibraryPath [
        hidapi
        libhidapi
      ]
    }'";
in

stdenv.mkDerivation (finalAttrs: {
  inherit (slimevr)
    src
    version
    ;

  pname = "slimevr-server";

  patches = [
    # Upstream code uses Git to find the program version
    (replaceVars ./no-grgit.patch {
      inherit (finalAttrs) version;
    })
  ];

  postPatch = ''
    # Disable Android, so its files don't have to be patched.
    substituteInPlace settings.gradle.kts \
      --replace-fail 'include(":server:android")' ""
  '';

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 server/desktop/build/libs/slimevr.jar $out/share/slimevr/slimevr.jar
    makeWrapper ${java}/bin/java $out/bin/slimevr-server \
        --add-flags "${javaOptions}" \
        --add-flags "-jar $out/share/slimevr/slimevr.jar"

    runHook postInstall
  '';

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "shadowJar";
  gradleFlags = [ "-Dorg.gradle.java.home=${java}" ];

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  passthru = {
    inherit java javaOptions;
    # `slimevr-server` is updated by the `slimevr` update script.
  };

  meta = {
    description = "App for facilitating full-body tracking in virtual reality";
    homepage = "https://docs.slimevr.dev/";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      gale-username
      loucass003
    ];

    platforms = with lib.platforms; darwin ++ linux;
    mainProgram = "slimevr-server";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
