{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "hyperblobs";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "holepunchto";
    repo = "hyperblobs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cj716lDyQj7IVbAmfQaKagfR1+ZYoQgOTXIn/3d+KEA=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-9/hoj+ktd5DyBjGnhPFpC3b7A+XjWWoFhbvvW+o8DBc=";
  doCheck = true;

  checkPhase = ''
    runHook preCheck

    npm run test

    runHook postCheck
  '';

  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Blob Store for Hypercore";
    homepage = "https://github.com/holepunchto/hyperblobs";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
