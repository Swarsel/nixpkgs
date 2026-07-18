{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  # webpack,
}:
buildNpmPackage (finalAttrs: {
  pname = "eslint";
  version = "10.7.0";

  src = fetchFromGitHub {
    owner = "eslint";
    repo = "eslint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DrmrPuFbEZzyfwFdJr/nAMq1xCugbyfJpJqN/qxsNCs=";
  };

  # NOTE: Generating lock-file
  # npm install --package-lock-only
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-9VeeXBpQMww3Xb+tum+8julwek86k6S5Afqx9E2Ta14=";

  # Delete dangling symlinks
  preFixup = ''
    rm $out/lib/node_modules/eslint/node_modules/{eslint-config-eslint,@eslint/js}
  '';

  dontNpmBuild = true;
  dontNpmPrune = true;
  npmInstallFlags = [ "--omit=dev" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--generate-lockfile" ];
  };

  meta = {
    description = "Find and fix problems in your JavaScript code";
    homepage = "https://eslint.org";
    changelog = "https://github.com/eslint/eslint/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mdaniels5757
      onny
    ];
  };
})
