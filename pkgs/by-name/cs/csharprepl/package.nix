{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:

buildDotnetGlobalTool {
  pname = "csharprepl";
  version = "0.6.7";
  # We're using an SDK here because it's a REPL, and it requires an SDK instead of a runtime
  dotnet-runtime = dotnetCorePackages.sdk_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetHash = "sha256-a0CiU3D6RZp1FF459NIUUry5TFRDgm4FRhqJZNAGYWs=";
  nugetName = "CSharpRepl";

  meta = {
    description = "C# REPL with syntax highlighting";
    homepage = "https://fuqua.io/CSharpRepl";
    changelog = "https://github.com/waf/CSharpRepl/blob/main/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ _4evy ];
    platforms = lib.platforms.unix;
    mainProgram = "csharprepl";
  };
}
