{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

let
  version = "2021.2.1";
  majorVersion = builtins.substring 0 6 version;
in

stdenv.mkDerivation rec {
  inherit version;
  pname = "flexibee";

  src = fetchurl {
    url = "https://download.flexibee.eu/download/${majorVersion}/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-WorRyfjWucV8UhAjvuW+22CRzPcz5tjXF7Has4wrLMI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    cp -R usr/share/flexibee/ $out/
    install -Dm755 usr/bin/flexibee $out/bin/flexibee
    install -Dm755 usr/sbin/flexibee-server $out/bin/flexibee-server
    wrapProgram $out/bin/flexibee --set JAVA_HOME "${jre}"
    wrapProgram $out/bin/flexibee-server --set JAVA_HOME "${jre}"
    runHook postInstall
  '';

  prePatch = ''
    substituteInPlace usr/sbin/flexibee-server \
      --replace "/usr/share/flexibee" $out \
      --replace "/var/run" "/run"
  '';

  meta = {
    description = "Client for an accouting economic system";
    homepage = "https://www.flexibee.eu/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.mmahut ];
    platforms = [ "x86_64-linux" ];
  };
}
