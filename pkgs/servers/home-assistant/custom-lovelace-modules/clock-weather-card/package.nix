{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  stdenvNoCC,
  yarnBuildHook,
  yarnConfigHook,
}:
stdenvNoCC.mkDerivation rec {
  pname = "clock-weather-card";
  version = "2.9.2";

  src = fetchFromGitHub {
    owner = "pkissling";
    repo = "clock-weather-card";
    tag = "v${version}";
    hash = "sha256-8srE601xz8AcFv+5swIUUqUlHif/Qfm1TdfA5HfDAnU=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./dist/clock-weather-card.js $out/

    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-hCniXzBsnTozR0PWEleTo7K9P/lqoKNF+L8EErjOdEg=";
    yarnLock = src + "/yarn.lock";
  };

  meta = {
    description = "Home Assistant Card indicating today's date/time, along with an iOS inspired weather forecast for the next days with animated icons";
    homepage = "https://github.com/pkissling/clock-weather-card";
    changelog = "https://github.com/pkissling/clock-weather-card/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oddlama ];
    platforms = lib.platforms.all;
  };
}
