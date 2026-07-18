{
  lib,
  fetchFromGitHub,
  buildDartApplication,
  callPackage,
  versionCheckHook,
}:
buildDartApplication (finalAttrs: {
  pname = "mono_repo";
  version = "6.6.3";

  # Fetch the whole monorepo
  src = fetchFromGitHub {
    owner = "google";
    repo = "mono_repo.dart";
    tag = "mono_repo-v${finalAttrs.version}";
    hash = "sha256-2/YJ2S3I9K5Xzje787HdJ/KxfbiBEGKU8feuHnOizn8=";
  };

  strictDeps = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  dartEntryPoints = {
    "bin/mono_repo" = "bin/mono_repo.dart";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/mono_repo";
  passthru.updateScript = lib.getExe (callPackage ./update.nix { });

  meta = {
    description = "CLI tools to make it easier to manage a single source repository containing multiple Dart packages";
    homepage = "https://dart.dev/tools/mono_repo";

    changelog = "https://pub.dev/packages/mono_repo/changelog#${
      lib.replaceString "." "" finalAttrs.version
    }";

    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ KristijanZic ];
    mainProgram = "mono_repo";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "google" finalAttrs.version;
  };
})
