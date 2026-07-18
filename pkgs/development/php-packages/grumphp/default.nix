{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "grumphp";
  version = "2.22.0";

  src = fetchFromGitHub {
    owner = "phpro";
    repo = "grumphp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qcgz6RWq5kzh0Vopkz3Gr1cU4lo/VNM6yAGQq4v34NY=";
  };

  vendorHash = "sha256-g6iKl+o0kzvjuxE4lJP783ey+pNH2CZCKBLAKPxjb+Y=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "PHP code-quality tool";
    homepage = "https://github.com/phpro/grumphp";
    changelog = "https://github.com/phpro/grumphp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "grumphp";
    teams = [ lib.teams.php ];
  };
})
