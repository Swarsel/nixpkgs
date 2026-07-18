{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
}:

buildGoModule (finalAttrs: {
  pname = "godns";
  version = "3.3.6";

  src = fetchFromGitHub {
    owner = "TimothyYe";
    repo = "godns";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YdIXMVtagF7uA9By6EHVdG2o5UwUi82XkYK26W5Fssg=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-wGaRJFxuhwwwP7CBZ7eY5uR95EMdpWiJuU43eWXtHNo=";

  preBuild = ''
    npm --prefix="$npmRoot" run build
    go generate ./...
  '';

  # Some tests require internet access, broken in sandbox
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/web";
    hash = "sha256-OsYBmDawDUCt/+s5kyOPawMA9BWQwJhd7TQNc55rPlc=";
  };

  npmRoot = "web";

  overrideModAttrs = oldAttrs: {
    # Do not add `npmConfigHook` to `goModules`
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    # Do not run `preBuild` when building `goModules`
    preBuild = null;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc";
    homepage = "https://github.com/TimothyYe/godns";
    changelog = "https://github.com/TimothyYe/godns/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ yinfeng ];
    mainProgram = "godns";
  };
})
