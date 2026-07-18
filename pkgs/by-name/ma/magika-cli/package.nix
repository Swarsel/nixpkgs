{
  lib,
  stdenv,
  fetchFromGitHub,
  magika-cli,
  nix-update-script,
  onnxruntime,
  openssl,
  pkg-config,
  runCommand,
  rustPlatform,
  testers,
  versionCheckHook,
  writeText,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "magika-cli";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "magika";
    tag = "cli/v${finalAttrs.version}";
    hash = "sha256-rxkyC8/4nnVqfoubXiOchvmmGI1Z6dC8j2Oqpbt9kE0=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    onnxruntime
  ];

  cargoHash = "sha256-08dbfb4F2A3hB2xKKqR/+BNG7M74HG5UZi4ejULwVRw=";

  env = {
    OPENSSL_NO_VENDOR = "true";
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    # Required to prevent "ort-sys could not link to the ONNX Runtime build":
    # https://github.com/pykeio/ort/issues/517#issuecomment-3761926178
    ORT_PREFER_DYNAMIC_LINK = "true";
    ORT_STRATEGY = "system";
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "rust/cli";

  passthru = {
    tests = {
      mime = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [
                magika-cli
              ];
            }
            ''
              magika --format '%m' '${./test.md}' >>"$out"
            '';

        assertion = "magika detects the correct language from content even when the file extension is wrong";

        # Magika does not support Nix files yet: https://github.com/google/magika/issues/1247
        expected = writeText "expected" ''
          application/x-rust
        '';
      };
    };

    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^cli/v([0-9.]+)$" ];
    };
  };

  meta = {
    description = "Determines file content types using AI";
    homepage = "https://securityresearch.google/magika/";
    changelog = "https://github.com/google/magika/releases/tag/cli/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kachick
    ];

    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "magika";
    # The package test fails on Darwin with this error, even though the build succeeds:
    # libc++abi: terminating due to uncaught exception of type std::__1::system_error: mutex lock failed: Invalid argument
    broken = stdenv.hostPlatform.isDarwin;
    downloadPage = "https://github.com/google/magika";
  };
})
