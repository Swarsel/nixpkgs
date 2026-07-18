{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpmd";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "phpmd";
    repo = "phpmd";
    tag = finalAttrs.version;
    hash = "sha256-nTuJGzOZnkqrfE9R9Vujz/zGJRLlj8+yRZmmnxWrieQ=";
  };

  vendorHash = "sha256-Vx5JolyOeCRst+wzqPB7bZopBa2LU7SOJmA4tEvWj1c=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Missing `composer.lock` from the repository.
  # Issue open at https://github.com/phpmd/phpmd/issues/1056
  composerLock = ./composer.lock;

  meta = {
    description = "PHP code quality analyzer";
    homepage = "https://phpmd.org/";
    changelog = "https://github.com/phpmd/phpmd/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    mainProgram = "phpmd";
    teams = [ lib.teams.php ];
  };
})
