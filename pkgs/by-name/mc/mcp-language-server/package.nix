{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "mcp-language-server";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "isaacphi";
    repo = "mcp-language-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T0wuPSShJqVW+CcQHQuZnh3JOwqUxAKv1OCHwZMr7KM=";
  };

  vendorHash = "sha256-niDJB3QhZjz9qIGSjUEcghRpEbPUgsSuK52ncZ21DS8=";
  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "Model Context Protocol server to interact with language servers";
    homepage = "https://github.com/isaacphi/mcp-language-server";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      fayash
    ];

    mainProgram = "mcp-language-server";
  };
})
