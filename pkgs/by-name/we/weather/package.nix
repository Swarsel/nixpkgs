{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "weather";
  version = "2.5.0";

  src = fetchurl {
    url = "https://fungi.yuggoth.org/weather/src/weather-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-wn3cpgfrlqntMIiVFh4317DrbGgQ4YRnFz3KHXacTw4=";
  };

  nativeBuildInputs = [
    installShellFiles
    python3.pkgs.wrapPython
  ];

  # Upstream doesn't provide a setup.py or alike, so we follow:
  # http://fungi.yuggoth.org/weather/doc/install.rst#id3
  installPhase = ''
    site_packages=$out/${python3.sitePackages}
    install -Dt $out/bin -m 755 weather
    install -Dt $site_packages weather.py
    install -Dt $out/share/weather-util \
      airports overrides.{conf,log} places slist stations \
      zctas zlist zones
    install -Dt $out/etc weatherrc

    sed -i \
      -e "s|/etc|$out/etc|g" \
      -e "s|else: default_setpath = \".:~/.weather|&:$out/share/weather-util|" \
      $site_packages/weather.py

    wrapPythonPrograms

    installManPage weather.1 weatherrc.5
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Quick access to current weather conditions and forecasts";
    homepage = "http://fungi.yuggoth.org/weather";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "weather";
  };
})
