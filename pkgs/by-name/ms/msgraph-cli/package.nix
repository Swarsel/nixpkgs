{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  libsecret,
}:
buildDotnetModule rec {
  pname = "msgraph-cli";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "microsoftgraph";
    repo = "msgraph-cli";
    tag = "v${version}";
    hash = "sha256-bpdxzVlQWQLNYTZHN25S6qa3NKHhDc+xV6NvzSNMVnQ=";
  };

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  projectFile = "src/msgraph-cli.csproj";
  runtimeDeps = [ libsecret ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Microsoft Graph CLI";
    homepage = "https://github.com/microsoftgraph/msgraph-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nazarewk ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "mgc";
  };
}
