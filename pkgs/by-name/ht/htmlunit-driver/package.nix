{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "htmlunit-driver-standalone";
  version = "2.27";

  src = fetchurl {
    url = "https://github.com/SeleniumHQ/htmlunit-driver/releases/download/${version}/htmlunit-driver-${version}-with-dependencies.jar";
    sha256 = "1sd3cwpamcbq9pv0mvcm8x6minqrlb4i0r12q3jg91girqswm2dp";
  };

  installPhase = "install -D $src $out/share/lib/${pname}-${version}/${pname}-${version}.jar";
  dontUnpack = true;

  meta = {
    description = "WebDriver server for running Selenium tests on the HtmlUnit headless browser";
    homepage = "https://github.com/SeleniumHQ/htmlunit-driver";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      coconnor
    ];

    platforms = lib.platforms.all;
  };
}
