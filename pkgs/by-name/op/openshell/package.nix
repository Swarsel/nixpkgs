{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  gitMinimal,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  z3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openshell";
  version = "0.0.36";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "OpenShell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AnZliQrn5kwaVJw1LEorT+VPtIk2NIbVY0QISxfnORs=";
  };

  postPatch = ''
    # fill in package version to Cargo
    substituteInPlace Cargo.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
    # only build openshell-cli crate
    substituteInPlace Cargo.toml \
      --replace-fail 'members = ["crates/*"]' 'members = ["crates/openshell-cli"]'
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [ z3 ];
  cargoHash = "sha256-kmmzzph39KaAXkEbjOHMoTRltX2ttqxtHppb6apoSSs=";

  env = {
    # docker image tag baked in at compile time, must match binary version
    OPENSHELL_IMAGE_TAG = finalAttrs.version;
  };

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    cacert
    gitMinimal
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "The safe, private runtime for autonomous AI agents.";

    longDescription = ''
      NVIDIA OpenShell is an open source runtime to build and deploy autonomous,
      self-evolving agents more safely. OpenShell sits between your agent and
      your infrastructure to govern how the agent executes, what the agent can
      see and do, and where inference goes. It enables claws to run in isolated
      sandboxes, with fine-grained control over privacy and security.
    '';

    homepage = "https://docs.nvidia.com/openshell/index.html";
    changelog = "https://github.com/NVIDIA/OpenShell/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ wishstudio ];
    platforms = lib.platforms.all;
    mainProgram = "openshell";
  };
})
