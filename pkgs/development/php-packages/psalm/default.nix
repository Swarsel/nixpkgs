{
  lib,
  fetchurl,
  fetchFromGitHub,
  php,
  runCommand,
  versionCheckHook,
}:

let
  version = "6.14.3";

  # The PHAR file is only required to get the `composer.lock` file
  psalm-phar = fetchurl {
    hash = "sha256-dqRI73CdY51K1aitIK6R74Y2sLb68l4ndNuTzRv8qRE=";
    url = "https://github.com/vimeo/psalm/releases/download/${version}/psalm.phar";
  };
in
php.buildComposerProject2 (finalAttrs: {
  inherit version;
  pname = "psalm";

  src = fetchFromGitHub {
    owner = "vimeo";
    repo = "psalm";
    tag = finalAttrs.version;
    hash = "sha256-6MO16Ch3SR2kn48lTj64c/1DZDpsLjpZcFYmtiBhCCU=";
  };

  vendorHash = "sha256-2LlP0D7b07yXVGc/+pJUUWYXF8rsc4HiErBUt5SfZmw=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  composerLock = runCommand "composer.lock" { } ''
    ${lib.getExe php} -r '$phar = new Phar("${psalm-phar}"); $phar->extractTo(".", "composer.lock");'
    cp composer.lock $out
  '';

  meta = {
    description = "Static analysis tool for finding errors in PHP applications";
    homepage = "https://github.com/vimeo/psalm";
    changelog = "https://github.com/vimeo/psalm/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    mainProgram = "psalm";
  };
})
