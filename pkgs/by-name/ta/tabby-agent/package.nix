{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  wrapGAppsHook3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tabby-agent";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "TabbyML";
    repo = "tabby";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OeHRJOg7UEOVBG7jTUGCpiuKZI0Jj7Gl7QDKpsjX5Bc=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_11
    wrapGAppsHook3
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter=tabby-agent build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r ./clients/tabby-agent/dist $out/dist
    ln -s $out/dist/node/index.js $out/bin/tabby-agent
    chmod +x $out/bin/tabby-agent

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-idEByCnQmqpnvni0RahZ7qEa0C/0zVPRFv0jaj3BcnM=";
    pnpm = pnpm_11;
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Language server used to communicate with Tabby server";
    homepage = "https://github.com/TabbyML/tabby";
    changelog = "https://github.com/TabbyML/tabby/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skohtv ];
    mainProgram = "tabby-agent";
  };
})
