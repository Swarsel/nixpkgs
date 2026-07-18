{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildGo126Module,
  gnugrep,
  gnused,
  nix,
  nix-update-script,
  versionCheckHook,
  writeShellApplication,
}:

let
  buildGoModule = buildGo126Module;
in
buildGoModule (finalAttrs: {
  pname = "typescript-go";
  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "typescript-go";
    tag = "typescript/v${finalAttrs.version}";
    hash = "sha256-fRejdQSwaxSS2pjHrbJO2CQgZS5lWJmBNEM/TgbJTJ8=";
    fetchSubmodules = false;
  };

  vendorHash = "sha256-q6dMb2ab4uZ3GTrcA7v2JzfmOM+ZzBcJN6gKOpLfM/k=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    ln -s "$out/bin/tsgo" "$out/bin/tsc"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/tsgo"
  ];

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [
          "--use-github-releases"
          "--version-regex=^typescript/v([\\d.]+)$"
          "--src-only"
        ];
      })

      (lib.getExe (writeShellApplication {
        name = "typescript-go-go-version-updater";

        runtimeInputs = [
          nix
          gnugrep
          gnused
        ];

        text = ''
          new_src="$(nix-build --attr 'pkgs.typescript-go.src' --no-out-link)"
          new_go_major_minor="$(grep --only-matching --perl-regexp '^go \K([0-9]+\.[0-9]+)' "$new_src/go.mod")"
          sed -i -E "s/buildGo[0-9]+Module/buildGo''${new_go_major_minor//./}Module/g" '${toString ./package.nix}'
        '';
      }))

      # Update vendorHash
      (nix-update-script {
        extraArgs = [ "--version=skip" ];
      })
    ];
  };

  meta = {
    description = "Go implementation of TypeScript";
    homepage = "https://github.com/microsoft/typescript-go";
    changelog = "https://github.com/microsoft/typescript-go/releases/tag/typescript/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kachick
    ];

    mainProgram = "tsc";
  };
})
