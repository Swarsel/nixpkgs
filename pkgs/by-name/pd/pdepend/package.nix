{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "pdepend";
  version = "2.16.2";

  src = fetchFromGitHub {
    owner = "pdepend";
    repo = "pdepend";
    tag = finalAttrs.version;
    hash = "sha256-2Ruubcm9IWZYu2LGeGeKm1tmHca0P5xlKYkuBCCV9ag=";
  };

  vendorHash = "sha256-IowPh4CymahgfbnvLS2QWu8e+TXya9AszTK+mlR/DTY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  composerLock = ./composer.lock;

  meta = {
    description = "Adaptation of JDepend for PHP";

    longDescription = "
      PHP Depend is an adaptation of the established Java
      development tool JDepend. This tool shows you the quality
      of your design in terms of extensibility, reusability and
      maintainability.
    ";

    homepage = "https://github.com/pdepend/pdepend";
    changelog = "https://github.com/pdepend/pdepend/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    mainProgram = "pdepend";
    teams = [ lib.teams.php ];
  };
})
