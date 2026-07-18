{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "k2tf";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "sl1pm4t";
    repo = "k2tf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LoYlX2kAfzI0GMUbBtvuOinDzvoHABKEaGhipe16FeA=";
  };

  vendorHash = "sha256-h8ph8K/4luTUCkx5X1iakTubF651HblGDN4G1EtSKeE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Kubernetes YAML to Terraform HCL converter";
    homepage = "https://github.com/sl1pm4t/k2tf";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.flokli ];
    mainProgram = "k2tf";
  };
})
