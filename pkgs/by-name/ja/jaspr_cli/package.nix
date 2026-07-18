{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  callPackage,
  testers,
  versionCheckHook,
  yq-go,
}:
# Note: Removed jaspr_cli from arguments because we use finalAttrs.finalPackage for tests
buildDartApplication (finalAttrs: {
  pname = "jaspr_cli";
  version = "0.23.0";

  # Fetch the whole monorepo
  src = fetchFromGitHub {
    owner = "schultek";
    repo = "jaspr";
    tag = "jaspr_cli-v${finalAttrs.version}";
    hash = "sha256-V+cmnO4I4hZEdxzjnycPCTQbWpBmjESJSG9cIoMIwjo=";
  };

  strictDeps = true;
  nativeBuildInputs = [ yq-go ];

  # Remove the resolution: workspace section.
  # Workspace dependencies break the Nix build which expects
  # all dependencies to be resolved via the lockfile.
  preBuild = ''
    yq -i 'del(.resolution)' pubspec.yaml
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  dartEntryPoints = {
    "bin/jaspr" = "bin/jaspr.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/packages/jaspr_cli";

  passthru = {
    tests = {
      # Smoke test: Can it initialize a project?
      # Note: Using --no-pub-get because Nix has no network access
      create-project = testers.runCommand {
        buildInputs = [ finalAttrs.finalPackage ];
        name = "jaspr-cli-create-test";

        script = ''
          export HOME=$TMPDIR
          jaspr create -t docs my_test_project --no-pub-get
          test -f my_test_project/pubspec.yaml
          touch $out
        '';
      };

      # Basic execution test
      help-text = testers.runCommand {
        # Use finalPackage to refer to the finished derivation
        buildInputs = [ finalAttrs.finalPackage ];
        name = "jaspr-cli-help-test";

        script = ''
          jaspr --help | grep "Usage: jaspr"
          touch $out
        '';
      };
    };

    updateScript = lib.getExe (callPackage ./update.nix { });
  };

  meta = {
    description = "Command line tools for Jaspr";

    longDescription = ''
      Command line tools for the Jaspr, a modern web framework for building websites in Dart. Supports SPAs, SSR and SSG.
    '';

    homepage = "https://jaspr.site";

    changelog = "https://pub.dev/packages/jaspr_cli/changelog#${
      lib.replaceString "." "" finalAttrs.version
    }";

    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ KristijanZic ];
    mainProgram = "jaspr";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "schultek" finalAttrs.version;
  };
})
