{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uesave";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "uesave-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lGtRe3AYJ59CwRaDznO6RNqVFCSKJPWVDhj0tnY5xcs=";
  };

  cargoHash = "sha256-6VTy/KHk2mSDfRonxyen4kRMvwBS3uZjsZqMhBJ+boM=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  meta = {
    description = "Reading and writing Unreal Engine save files (commonly referred to as GVAS)";
    homepage = "https://github.com/trumank/uesave-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "uesave";
  };
})
