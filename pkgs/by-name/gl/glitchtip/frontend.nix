{
  lib,
  fetchFromGitLab,
  buildNpmPackage,
  fetchNpmDeps,
  jq,
  moreutils,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "glitchtip-frontend";
  version = "6.2.0";

  src = fetchFromGitLab {
    owner = "glitchtip";
    repo = "glitchtip-frontend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iKY1w9lmfuyvDblH/TlnUwAnda17qWGxmx1qtmQRENg=";
  };

  postPatch = ''
    jq '.devDependencies |= del(.cypress, ."cypress-localstorage-commands")' package.json | sponge package.json
  '';

  nativeBuildInputs = [
    moreutils
    jq
  ];

  buildPhase = ''
    runHook preBuild

    npm run build-prod

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/glitchtip-frontend/browser $out/

    runHook postInstall
  '';

  nodejs = nodejs_22;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-V9aRKoJ6+BN/q7NS21eZBopzkWje8sOGGL1AgO4cUM0=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    npmDepsFetcherVersion = 3;
  };

  meta = {
    description = "Frontend for GlitchTip";
    homepage = "https://glitchtip.com";
    changelog = "https://gitlab.com/glitchtip/glitchtip-frontend/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      defelo
      felbinger
    ];
  };
})
