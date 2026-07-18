{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  onnxruntime,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "icm";
  version = "0.10.53";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "icm";
    tag = "icm-v${finalAttrs.version}";
    hash = "sha256-fx7RPt32Vuy0j+Ab9VtqXoJ/+Ql5h4ORNPYwARlll0U=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    onnxruntime
  ];

  cargoHash = "sha256-5xlgEjQWPQEtLDzP403lFIEa2dvdsX6HujWMmCiFnD8=";

  env = {
    # Use system OpenSSL instead of vendoring it
    OPENSSL_NO_VENDOR = "1";
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    # Point ort (ONNX Runtime bindings) at the system library
    ORT_STRATEGY = "system";
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  # Build the HTTP dashboard
  buildFeatures = [ "web" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^icm-(.*)"
    ];
  };

  meta = {
    description = "Permanent memory system for AI agents with MCP integration";
    homepage = "https://github.com/rtk-ai/icm";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
    platforms = lib.platforms.unix;
    mainProgram = "icm";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
