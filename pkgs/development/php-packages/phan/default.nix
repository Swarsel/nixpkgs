{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

(php.withExtensions ({ all, enabled }: enabled ++ (with all; [ ast ]))).buildComposerProject2
  (finalAttrs: {
    pname = "phan";
    version = "6.0.7";

    src = fetchFromGitHub {
      owner = "phan";
      repo = "phan";
      tag = finalAttrs.version;
      hash = "sha256-etqvZM1YWBXUapL+OIxuB1iVoY6kbS0fgLWVNx5Nb2A=";
    };

    vendorHash = "sha256-4PJWNPIikfWwIbrHr1c3yPOP68+bNlwjT9GkJJZoOFc=";
    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];
    composerStrictValidation = false;
    versionCheckProgramArg = "--version";

    meta = {
      description = "Static analyzer for PHP";

      longDescription = ''
        Phan is a static analyzer for PHP. Phan prefers to avoid false-positives
        and attempts to prove incorrectness rather than correctness.
      '';

      homepage = "https://github.com/phan/phan";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "phan";
      teams = [ lib.teams.php ];
    };
  })
