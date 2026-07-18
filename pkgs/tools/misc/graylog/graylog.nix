{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nixosTests,
  openjdk11_headless,
  openjdk17_headless,
  systemd,
}:

{
  hash,
  license,
  maintainers,
  version,
}:
stdenv.mkDerivation rec {
  inherit version;
  pname = "graylog_${lib.versions.majorMinor version}";

  src = fetchurl {
    inherit hash;
    url = "https://packages.graylog2.org/releases/graylog/graylog-${version}.tgz";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    cp -r {graylog.jar,bin,plugin} $out
  ''
  + lib.optionalString (lib.versionOlder version "4.3") ''
    cp -r lib $out
  ''
  + ''
    wrapProgram $out/bin/graylogctl $makeWrapperArgs
  '';

  dontBuild = true;

  makeWrapperArgs = [
    "--set-default"
    "JAVA_HOME"
    "${if (lib.versionAtLeast version "5.0") then openjdk17_headless else openjdk11_headless}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ systemd ]}"
  ];

  passthru.tests = { inherit (nixosTests) graylog; };

  meta = {
    inherit license;
    inherit maintainers;
    description = "Open source log management solution";
    homepage = "https://www.graylog.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
    mainProgram = "graylogctl";
  };
}
