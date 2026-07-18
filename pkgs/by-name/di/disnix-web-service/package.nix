{
  lib,
  stdenv,
  fetchFromGitHub,
  ant,
  axis2,
  dbus_java,
  fetchpatch,
  jdk8,
  xmlstarlet,
}:
let
  jdk = jdk8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "disnix-web-service";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = "DisnixWebService";
    rev = "DisnixWebService-${finalAttrs.version}";
    hash = "sha256-zcYr2Ytx4pevSthTQLpnQ330wDxN9dWsZA20jbO6PxQ=";
  };

  patches = [
    # Correct the DisnixWebService build for compatibility with Axis2 1.8.1
    # See https://github.com/svanderburg/DisnixWebService/pull/2
    (fetchpatch {
      hash = "sha256-4rSEN8AwivUXUCIUYFBRIoE19jVDv+Vpgakmy8fR06A=";
      url = "https://github.com/svanderburg/DisnixWebService/commit/cee99c6af744b5dda16728a70ebd2800f61871a0.patch";
    })
  ];

  nativeBuildInputs = [
    ant
    jdk
    xmlstarlet
  ];

  env = {
    AXIS2_LIB = "${axis2}/lib";
    AXIS2_WEBAPP = "${axis2}/webapps/axis2";
    DBUS_JAVA_LIB = "${dbus_java}/share/java";
    PREFIX = placeholder "out";
  };

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ant install
    runHook postInstall
  '';

  prePatch = ''
    # add modificationtime="0" to the <jar> and <war> tasks to achieve reproducibility
    xmlstarlet ed -L -a "//jar|//war" -t attr -n "modificationtime" -v "0" build.xml

    substituteInPlace scripts/disnix-soap-client \
      --replace-fail "#JAVA_HOME=" ${lib.escapeShellArg "JAVA_HOME=${jdk}"} \
      --replace-fail "#AXIS2_LIB=" "AXIS2_LIB=$AXIS2_LIB"
  '';

  meta = {
    description = "SOAP interface and client for Disnix";
    homepage = "https://github.com/svanderburg/DisnixWebService";
    changelog = "https://github.com/svanderburg/DisnixWebService/blob/${finalAttrs.src.rev}/NEWS.txt";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "disnix-soap-client";
  };
})
