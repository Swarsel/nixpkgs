{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  cairo,
  nix-update-script,
  pango,
  pixman,
  pkg-config,
}:

buildNpmPackage (finalAttrs: {
  pname = "vega-lite";
  version = "6.4.3";

  src = fetchFromGitHub {
    owner = "vega";
    repo = "vega-lite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bsPnvUleHrihsoOL98O8KTbiONx3FNuQjH9vrZ/bLTw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    pixman
    pango
  ];

  npmDepsHash = "sha256-dni2tEYzE/AzgGldCAtBpmQK24kIRck0KQXvD2e5xfw=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Concise grammar of interactive graphics, built on Vega";
    homepage = "https://vega.github.io/vega-lite/";
    changelog = "https://github.com/vega/vega-lite/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
