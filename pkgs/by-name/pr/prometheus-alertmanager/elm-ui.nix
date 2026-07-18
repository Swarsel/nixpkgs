{
  buildNpmPackage,
  elmPackages,
  prometheus-alertmanager,
}:

buildNpmPackage (finalAttrs: {
  inherit (prometheus-alertmanager) src version meta;
  pname = "alertmanager-elm-ui";

  postPatch = ''
    # don't download elm from github
    sed -i '/"elm":/d' package.json
  '';

  nativeBuildInputs = [
    elmPackages.elm
  ];

  npmDepsHash = "sha256-2flvNJXsOhE0k10Eu8kWo3p3aAABFB/f3yeYNrIztpw=";

  postConfigure = (
    elmPackages.fetchElmDeps {
      # elm2nix convert > elm-srcs.nix
      elmPackages = import ./elm-srcs.nix;
      elmVersion = elmPackages.elm.version;
      # elm2nix snapshot > registry.dat
      registryDat = ./registry.dat;
    }
  );

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r dist/* $out/
    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/ui/app";
})
