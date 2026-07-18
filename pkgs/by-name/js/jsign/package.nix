{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  jre_headless,
  makeBinaryWrapper,
  maven,
  opensc,
  pcsclite,
  yubico-piv-tool,
}:

let
  jre = jre_headless;
in
maven.buildMavenPackage rec {
  pname = "jsign";
  # For build from non-release, increment version by one and add -SNAPSHOT
  # e.g. 7.3-SNAPSHOT
  version = "7.4";

  src = fetchFromGitHub {
    owner = "ebourg";
    repo = "jsign";
    tag = version;
    hash = "sha256-r19w9k6Iuk6AQGC3l2yu6Ocn740BtE7DjtFLXUdhdw8=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  # The tests try to access the network
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    install -Dm644 jsign/target/jsign-${version}.jar $out/share/jsign.jar

    makeWrapper ${jre}/bin/java $out/bin/jsign \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          yubico-piv-tool
          opensc
        ]
      } \
      --add-flags "-Dsun.security.smartcardio.library=${lib.getLib pcsclite}/lib/libpcsclite.so.1 -jar $out/share/jsign.jar"

    runHook postInstall
  '';

  mvnHash = "sha256-zxlwb2id8yAw/yxTjD6jyAkPJx9IazrPQYGacQGLEK8=";

  meta = {
    description = "Authenticode signing for Windows executables, installers & scripts";
    homepage = "https://ebourg.github.io/jsign";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      johnazoidberg
    ];

    platforms = lib.platforms.all;
    mainProgram = "jsign";
    # Build doesn't work, upstream says running the .jar is supported on darwin though
    broken = stdenv.hostPlatform.isDarwin;
  };
}
