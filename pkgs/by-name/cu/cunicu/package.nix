{
  lib,
  stdenv,
  buildGoModule,
  fetchFromCodeberg,
  installShellFiles,
  nix-update-script,
  protobuf,
  protoc-gen-go,
  protoc-gen-go-grpc,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "cunicu";
  version = "0.12.0";

  src = fetchFromCodeberg {
    owner = "cunicu";
    repo = "cunicu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1y9olRSPu2akvE728oXBr70Pt03xj65R2GaOlZ/7RTg=";
  };

  nativeBuildInputs = [
    installShellFiles
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
  ];

  vendorHash = "sha256-yFpkYI6ue5LXwRCj4EqWDBaO3TYzZ3Ov/39PRQWMWzk=";
  env.CGO_ENABLED = 0;

  preBuild = ''
    go generate ./...
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/cunicu docs --with-frontmatter
    installManPage ./docs/usage/man/*.1
    installShellCompletion --cmd cunicu \
      --bash <($out/bin/cunicu completion bash) \
      --zsh <($out/bin/cunicu completion zsh) \
      --fish <($out/bin/cunicu completion fish)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # These packages contain networking dependent tests which fail in the sandbox
  excludedPackages = [
    "pkg/config"
    "pkg/selfupdate"
    "pkg/tty"
    "scripts"
  ];

  ldflags = [
    "-X cunicu.li/cunicu/pkg/buildinfo.Version=${finalAttrs.version}"
    "-X cunicu.li/cunicu/pkg/buildinfo.BuiltBy=Nix"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zeroconf peer-to-peer mesh VPN using Wireguard® and Interactive Connectivity Establishment (ICE)";
    homepage = "https://cunicu.li";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stv0g ];
    platforms = lib.platforms.linux;
    mainProgram = "cunicu";
  };
})
