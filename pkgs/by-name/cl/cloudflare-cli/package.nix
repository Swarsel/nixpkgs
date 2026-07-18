{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cloudflare-cli";
  version = "5.1.7";

  src = fetchFromGitHub {
    owner = "danielpigott";
    repo = "cloudflare-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3I8KvP9nlkiyYi4h7LpP5LE9xR+uvQyfkLLdSmDaG7E=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
    makeBinaryWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/cfcli \
      --chdir $out/lib/node_modules/cloudflare-cli
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/cfcli --help >/dev/null

    runHook postInstallCheck
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-XCqKC/uATKsWaqF9FnEd/p+CRl2OFP7zdmz7LAkm5HQ=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for interacting with Cloudflare";
    homepage = "https://github.com/danielpigott/cloudflare-cli";
    changelog = "https://github.com/danielpigott/cloudflare-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "cfcli";
  };
})
