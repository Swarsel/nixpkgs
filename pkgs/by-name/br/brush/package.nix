{
  lib,
  fetchFromGitHub,
  brush,
  nix-update-script,
  runCommand,
  rustPlatform,
  testers,
  versionCheckHook,
  writeText,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    tag = "brush-shell-v${finalAttrs.version}";
    hash = "sha256-zG6ho/QECzLC/evOUdo9mYXoh4xA2PF+BQvnCsLZiNg=";
  };

  cargoHash = "sha256-NSvlLiLp0kdnWNUSIateGkscL5as+b00d54CP3sEakI=";
  # Found argument '--test-threads' which wasn't expected, or isn't valid in this context
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  passthru = {
    shellPath = "/bin/brush";

    tests = {
      complete = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [ brush ];
            }
            ''
              brush -c 'brushinfo complete line bru' >$out
            '';

        assertion = "brushinfo performs to inspect completions";

        expected = writeText "expected" ''
          brush
          brushctl
          brushinfo
        '';
      };
    };

    updateScript = nix-update-script { extraArgs = [ "--version-regex=brush-shell-v([\\d\\.]+)" ]; };
  };

  meta = {
    description = "Bash/POSIX-compatible shell implemented in Rust";
    homepage = "https://github.com/reubeno/brush";
    changelog = "https://github.com/reubeno/brush/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kachick ];
    mainProgram = "brush";
  };
})
