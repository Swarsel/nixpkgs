{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "mini-graph-card";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "kalkih";
    repo = "mini-graph-card";
    tag = "v${version}";
    hash = "sha256-flZfOVY0/xZOL1ZktRGQhRyGAZronLAjpM0zFpc+X1U=";
  };

  npmDepsHash = "sha256-xzhyYYZLl8pyfK3+MRn35Ffdw/c78v8PjwLlAuQO92g=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v dist/mini-graph-card-bundle.js $out/

    runHook postInstall
  '';

  passthru.entrypoint = "mini-graph-card-bundle.js";

  meta = {
    description = "Minimalistic graph card for Home Assistant Lovelace UI";
    homepage = "https://github.com/kalkih/mini-graph-card";
    changelog = "https://github.com/kalkih/mini-graph-card/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
