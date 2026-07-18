{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  zig,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-zigbuild";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "rust-cross";
    repo = "cargo-zigbuild";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y73aPGsrSAZVxNJ1r1lS9uXmfpAwthq6NW4urKS8ab0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-dt2s18B9RVwEBlun5cegoqfW1KYXFqjdScdc/Q2aDlI=";

  postInstall = ''
    wrapProgram $out/bin/cargo-zigbuild \
      --prefix PATH : ${zig}/bin
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to compile Cargo projects with zig as the linker";
    homepage = "https://github.com/rust-cross/cargo-zigbuild";
    changelog = "https://github.com/rust-cross/cargo-zigbuild/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "cargo-zigbuild";
  };
})
