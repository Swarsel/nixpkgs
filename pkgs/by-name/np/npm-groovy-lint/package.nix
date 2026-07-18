{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  jdk,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "npm-groovy-lint";
  version = "17.0.5";

  src = fetchFromGitHub {
    owner = "nvuillam";
    repo = "npm-groovy-lint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cq4SPOqR2mb2Foc1jlrA6B7qJBcmgLfcC84iTc4+tcw=";
  };

  strictDeps = true;
  npmDepsHash = "sha256-XGXiuqA0JmuFVretXDjWejV9HJAK6eWR9/LR3rUI99s=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ jdk ])
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lint, format and auto-fix your Groovy / Jenkinsfile / Gradle files using command line";
    homepage = "https://github.com/nvuillam/npm-groovy-lint";
    changelog = "https://github.com/nvuillam/npm-groovy-lint/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jlesquembre ];
    platforms = lib.platforms.all;
    mainProgram = "npm-groovy-lint";
  };
})
