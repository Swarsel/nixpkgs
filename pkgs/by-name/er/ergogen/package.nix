{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "ergogen";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "ergogen";
    repo = "ergogen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pddohqq08w/PpU3ZF3tCGSjUMLKnhCn/Db6WLKytjo0=";
  };

  npmDepsHash = "sha256-gSF4L4QiScW3ZaAm8QFCBGhbw7NhFe4gHWitN/OuQi4=";
  env.NODE_OPTIONS = "--openssl-legacy-provider";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontNpmBuild = true;
  forceGitDeps = true;
  makeCacheWritable = true;
  npmPackFlags = [ "--ignore-scripts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ergonomic keyboard layout generator";
    homepage = "https://ergogen.xyz";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Tygo-van-den-Hurk ];
    mainProgram = "ergogen";
  };
})
