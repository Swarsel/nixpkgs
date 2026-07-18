{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "svelte-check";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "sveltejs";
    repo = "language-tools";
    tag = "svelte-check-${finalAttrs.version}";
    hash = "sha256-+KDl7tTyXo6QMQpMGA4hSChDaPrfqfVKJXGunTlo9Rg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run --filter=svelte-check... build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm install --filter=svelte-check... --frozen-lockfile --offline --force --ignore-scripts
    mkdir -p $out/lib/node_modules/svelte-check/
    mkdir -p $out/bin

    mv {packages,node_modules} $out/lib/node_modules/svelte-check/

    makeWrapper ${lib.getExe nodejs} $out/bin/svelte-check \
      --add-flags "$out/lib/node_modules/svelte-check/packages/svelte-check/bin/svelte-check" \
      --set NODE_PATH "$out/lib/node_modules/svelte-check/packages/svelte-check/node_modules/"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-43AIkVzpcq/Y+QO2k7pkr6CN340idXJEpie0gVdxra8=";
  };

  pnpmWorkspaces = [ "svelte-check..." ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version-regex"
      "svelte-check-(.*)"
    ];
  };

  meta = {
    description = "Svelte code checker";
    homepage = "https://github.com/sveltejs/language-tools";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "svelte-check";
    downloadPage = "https://www.npmjs.com/package/svelte-check";
  };
})
