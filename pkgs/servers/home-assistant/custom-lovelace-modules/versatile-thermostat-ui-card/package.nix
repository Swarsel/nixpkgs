{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "versatile-thermostat-ui-card";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "jmcollin78";
    repo = "versatile-thermostat-ui-card";
    rev = "${version}";
    hash = "sha256-z0m9Ewgh9eaN4cd+H0cuIYoeNjxyfm5FiP4kblQVKXs=";
  };

  npmDepsHash = "sha256-5g+biez7e4+1YIrnHfBhN4+LeHF6motEX+1wl7NJdJI=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/versatile-thermostat-ui-card.js $out

    runHook postInstall
  '';

  npmFlags = [ "--legacy-peer-deps" ];

  meta = {
    description = "Home Assistant card for the Versatile Thermostat integration";
    homepage = "https://github.com/jmcollin78/versatile-thermostat-ui-card";
    changelog = "https://github.com/jmcollin78/versatile-thermostat-ui-card/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pwoelfel ];
  };
}
