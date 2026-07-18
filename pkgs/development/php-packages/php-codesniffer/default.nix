{
  lib,
  fetchFromGitHub,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "php-codesniffer";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "PHPCSStandards";
    repo = "PHP_CodeSniffer";
    tag = finalAttrs.version;
    hash = "sha256-63W9GMTDrIIMWSieYjv+xAHEj9xjsnvXsUXQ1I7fQFo=";
  };

  vendorHash = "sha256-h+EVwPtIeXnVHEMCMYJFwuqeWXvZaYLTxrb/RKycIx0=";

  meta = {
    description = "PHP coding standard tool";
    homepage = "https://github.com/PHPCSStandards/PHP_CodeSniffer/";
    changelog = "https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ javaguirre ];
    teams = [ lib.teams.php ];
  };
})
