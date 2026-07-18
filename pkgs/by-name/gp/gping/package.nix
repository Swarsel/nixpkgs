{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  iputils,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gping";
  version = "1.20.1";

  src = fetchFromGitHub {
    owner = "orf";
    repo = "gping";
    tag = "gping-v${finalAttrs.version}";
    hash = "sha256-whHbGZnxOQ/ISyWMl6miuogppZahgXxO3XmhcP6ymIo=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-b3Nv+mobPUcgREaNvn7cXra24PgEUe60yE/kOPTQEos=";
      name = "fix-ipv6-addrs-by-using-ping-dash-6.patch";
      # https://github.com/orf/gping/pull/546
      url = "https://github.com/orf/gping/commit/7ef8e1ddec847681c5ef3d4a010a0ad3a7aebab0.patch";
    })
  ];

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-F0QBL7tCCdjnavClqrw8yYxFrY8y4f8h/gcHSpEqBiM=";
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isLinux [ iputils ];

  # Requires internet access
  checkFlags = [
    "--skip=test::tests::test_integration_any"
    "--skip=test::tests::test_integration_ip6"
    "--skip=test::tests::test_integration_ipv4"
  ];

  postInstall = ''
    installManPage gping.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ping, but with a graph";
    homepage = "https://github.com/orf/gping";
    changelog = "https://github.com/orf/gping/releases/tag/gping-v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cafkafk ];
    mainProgram = "gping";
  };
})
