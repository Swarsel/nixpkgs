{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stylelint-lsp";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "bmatcuk";
    repo = "stylelint-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LUX/H7yY8Dl44vgpf7vOgtMdY7h//m5BAfrK5RRH9DM=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_9
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  preInstall = ''
    # remove unnecessary files
    CI=true pnpm --ignore-scripts prune --prod
    rm -rf node_modules/.pnpm/typescript*
    find -type f \( -name "*.ts" -o -name "*.map" \) -exec rm -rf {} +
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/stylelint-lsp}
    mv {dist,node_modules} $out/lib/stylelint-lsp
    chmod a+x $out/lib/stylelint-lsp/dist/index.js
    ln -s $out/lib/stylelint-lsp/dist/index.js $out/bin/stylelint-lsp

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-qzUvA00ujnIibQAONOPlp5BsXcwQb/gQvOPp83hMT5A=";
    pnpm = pnpm_9;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stylelint Language Server";
    homepage = "https://github.com/bmatcuk/stylelint-lsp";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gepbird
    ];

    platforms = lib.platforms.unix;
    mainProgram = "stylelint-lsp";
  };
})
