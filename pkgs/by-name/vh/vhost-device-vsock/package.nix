{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vhost-device-vsock";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rust-vmm";
    repo = "vhost-device";
    tag = "vhost-device-vsock-v${finalAttrs.version}";
    hash = "sha256-g+u6WBJtizIgQwC0kkWdAcTiYCM1zMI4YBLVRU4MOrs=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-mtORRCY/TNeIEgRCQ1ZbjpsykteRm2FHRveKaQxD/Pw=";

  postInstall = ''
    installManPage vhost-device-vsock/*.1
  '';

  __structuredAttrs = true;
  cargoBuildFlags = "-p vhost-device-vsock";
  cargoTestFlags = "-p vhost-device-vsock";

  meta = {
    homepage = "https://github.com/rust-vmm/vhost-device/blob/main/vhost-device-vsock/README.md";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.linux;
  };
})
