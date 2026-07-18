{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "node-core-utils";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "node-core-utils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VGl2Tz3oErFXrmnekVAGMSYiCn4sFuTWlzn5EWvKbcw=";
  };

  npmDepsHash = "sha256-NQSWOALsSfv2rjQW3gQDIYw28zDETRxKYaqHMPgUqew=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontNpmBuild = true;
  dontNpmPrune = true;
  npmInstallFlags = [ "--omit=dev" ];
  versionCheckProgram = "${placeholder "out"}/bin/git-node";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tools for Node.js Core collaborators";
    homepage = "https://github.com/nodejs/node-core-utils";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aduh95 ];
  };
})
