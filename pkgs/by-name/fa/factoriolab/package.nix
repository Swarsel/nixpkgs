{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  jq,
  makeWrapper,
  nix-update-script,
  pkg-config,
  vips,
}:
buildNpmPackage rec {
  pname = "factoriolab";
  version = "3.21.2";

  src = fetchFromGitHub {
    owner = "factoriolab";
    repo = "factoriolab";
    tag = "v${version}";
    hash = "sha256-9RmCdU2LertIZ8crZZGHQbiev6T2dIcWkuAczQyIrJg=";
    fetchLFS = true;
  };

  # By default angular tries to optimize fonts by inlining them
  # which needs internet access during building to download said fonts.
  # Internet access during build would necessitate turning this into a fixed output derivation
  # which is difficult as said fonts are not actually stable.
  # This disables font inlining completely in which case the fonts will be loaded on demand by your browser
  postPatch = ''
    ${lib.getExe jq} '.projects.factoriolab.architect.build.options += { "optimization": {"fonts": false } }' ./angular.json > angular.json.new
    mv -f angular.json.new angular.json
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ vips ];
  npmDepsHash = "sha256-FX9zxq3kIQ5nxEPW57X53novtCFBPV5w9jg882EC2Lo=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    cp -r dist/browser $out/share/factoriolab

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Angular-based calculator for factory games like Factorio and Dyson Sphere Program";
    homepage = "https://github.com/factoriolab/factoriolab";
    changelog = "https://github.com/factoriolab/factoriolab/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ patrickdag ];
  };
}
