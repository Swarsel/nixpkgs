{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rq";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "dflemstr";
    repo = "rq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QyYTbMXikLSe3eYJRUALQJxUJjA6VlvaLMwGrxIKfZI=";
  };

  postPatch = ''
    # Remove #[deny(warnings)] which is equivalent to -Werror in C.
    # Prevents build failures when upgrading rustc, which may give more warnings.
    substituteInPlace src/lib.rs \
      --replace-fail "#![deny(warnings)]" ""

    # build script tries to get version information from git
    # this fixes the --version output
    rm build.rs
  '';

  cargoHash = "sha256-BwbGiLoygNUua+AAKw/JAAG1kuWLdnP+8o+FFuvbFlM=";
  env.VERGEN_SEMVER = finalAttrs.version;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool for doing record analysis and transformation";
    homepage = "https://github.com/dflemstr/rq";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "rq";
  };
})
