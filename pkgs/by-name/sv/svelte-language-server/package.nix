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
  pname = "svelte-language-server";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "sveltejs";
    repo = "language-tools";
    tag = "svelte-language-server@${finalAttrs.version}";
    hash = "sha256-YKWH0LCZuNrOJFxQLDzY0pMDNFmwPML86KzbuFozrZA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run --filter=svelte-language-server... build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm install --filter=svelte-language-server... --prod --frozen-lockfile --offline --force --ignore-scripts
    mkdir -p $out/lib/node_modules/svelte-language-server/
    mkdir -p $out/bin

    mv {packages,node_modules} $out/lib/node_modules/svelte-language-server/

    makeWrapper ${lib.getExe nodejs} $out/bin/svelteserver \
      --add-flags "$out/lib/node_modules/svelte-language-server/packages/language-server/bin/server.js" \
      --set NODE_PATH "$out/lib/node_modules/svelte-language-server/packages/language-server/node_modules/"

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
    hash = "sha256-PLbmxjqfS5HHU8EKFdZwSNzN4Yl1ShTilqvpwap5noI=";
  };

  pnpmWorkspaces = [ "svelte-language-server..." ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version-regex"
      "svelte-language-server@(.*)"
    ];
  };

  meta = {
    description = "Language server (implementing the language server protocol) for Svelte";
    homepage = "https://github.com/sveltejs/language-tools";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "svelteserver";
    downloadPage = "https://www.npmjs.com/package/svelte-language-server";
  };
})
