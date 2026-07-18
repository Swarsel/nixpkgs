{
  lib,
  stdenv,
  fetchurl,
  chromedriver,
  htmlunit-driver,
  jre,
  makeWrapper,
  chromeSupport ? true,
}:

let
  minorVersion = "3.141";
  patchVersion = "59";

in
stdenv.mkDerivation rec {
  pname = "selenium-server-standalone";
  version = "${minorVersion}.${patchVersion}";

  src = fetchurl {
    url = "https://selenium-release.storage.googleapis.com/${minorVersion}/selenium-server-standalone-${version}.jar";
    sha256 = "1jzkx0ahsb27zzzfvjqv660x9fz2pbcddgmhdzdmasxns5vipxxc";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    mkdir -p $out/share/lib/${pname}-${version}
    cp $src $out/share/lib/${pname}-${version}/${pname}-${version}.jar
    makeWrapper ${jre}/bin/java $out/bin/selenium-server \
      --add-flags "-cp $out/share/lib/${pname}-${version}/${pname}-${version}.jar:${htmlunit-driver}/share/lib/${htmlunit-driver.name}/${htmlunit-driver.name}.jar" \
      ${lib.optionalString chromeSupport "--add-flags -Dwebdriver.chrome.driver=${chromedriver}/bin/chromedriver"} \
      --add-flags "org.openqa.grid.selenium.GridLauncherV3"
  '';

  dontUnpack = true;

  meta = {
    description = "Selenium Server for remote WebDriver";
    homepage = "http://www.seleniumhq.org/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      coconnor
    ];

    platforms = lib.platforms.all;
    mainProgram = "selenium-server";
  };
}
