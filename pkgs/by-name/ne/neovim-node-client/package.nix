{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchNpmDeps,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage rec {
  pname = "node-client";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "neovim";
    repo = "node-client";
    tag = "v${version}";
    hash = "sha256-nAV0X5882Ps5zDPfmoRHm0a0NtzCOpBQEZqOT2/GCZU=";
  };

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  postInstall = ''
    mkdir $out/bin
    ln -s $out/lib/node_modules/neovim/node_modules/.bin/neovim-node-host $out/bin/neovim-node-host
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-AN3TVvCyWjjm1GfnI+ZMt27KQC7qYxQ0bcysAaDsyz4=";
  };

  versionCheckProgram = "${placeholder "out"}/bin/neovim-node-host";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Nvim msgpack API client and remote plugin provider";
    homepage = "https://github.com/neovim/node-client";
    changelog = "https://github.com/neovim/node-client/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fidgetingbits ];
    mainProgram = "neovim-node-host";
  };
}
