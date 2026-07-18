{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "js-beautify";
  version = "1.15.4";

  src = fetchFromGitHub {
    owner = "beautifier";
    repo = "js-beautify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7heFAt8ArwBox0R2UFAYyzqyARPLnVtlWmPr0txuxOM=";
  };

  npmDepsHash = "sha256-Tr8kYawvPBt+jC7SW8dnKJVWynQyOpKbRD8yd+qbvIs=";

  preBuild = ''
    patchShebangs ./*

    substituteInPlace Makefile \
      --replace-fail "/bin/bash" "bash" \
      --replace-fail "\$(SCRIPT_DIR)/node" "${nodejs}/bin/node" \
      --replace-fail "\$(SCRIPT_DIR)/npm" "${nodejs}/bin/npm"
  '';

  buildPhase = ''
    runHook preBuild
    make js
    runHook postBuild
  '';

  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beautifier for javascript";
    homepage = "https://beautifier.io/";
    changelog = "https://github.com/beautifier/js-beautify/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "js-beautify";
  };
})
