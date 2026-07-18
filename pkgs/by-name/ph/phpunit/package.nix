{
  lib,
  fetchFromGitHub,
  nix-update-script,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpunit";
  version = "13.2.1";

  src = fetchFromGitHub {
    owner = "sebastianbergmann";
    repo = "phpunit";
    tag = finalAttrs.version;
    hash = "sha256-bwedO6b4gL3FiddxmOnPn0czIV2UwCiV5iM1Cu7kFR0=";
  };

  vendorHash = "sha256-u89MpsCKwYn44/69evX+a+SJtqMctx6uCXnhKEdqhTE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "PHP Unit Testing framework";
    homepage = "https://phpunit.de";
    changelog = "https://github.com/sebastianbergmann/phpunit/blob/${finalAttrs.version}/ChangeLog-${lib.versions.majorMinor finalAttrs.version}.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      onny
      patka
    ];

    mainProgram = "phpunit";
  };
})
