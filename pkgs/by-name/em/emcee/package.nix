{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "emcee";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "mattt";
    repo = "emcee";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S3hSexTjedfmjLuFHXtyiDiKM4NaLeUIJCEl2PKAOCw=";
  };

  vendorHash = "sha256-e8LPcKue7rhAh03uCRG0VTcwwyj3kDOBoeo3t7Hwvi0=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Connect agents to APIs";

    longDescription = ''
      emcee is a tool that provides a Model Context Protocol (MCP) server
      for any web application with an OpenAPI specification.
      You can use emcee to connect Claude Desktop
      and other apps to external tools and data services, similar to ChatGPT plugins.
    '';

    homepage = "https://github.com/mattt/emcee";
    changelog = "https://github.com/mattt/emcee/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "emcee";
  };
})
