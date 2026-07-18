{ lib, buildDotnetGlobalTool }:
buildDotnetGlobalTool {
  pname = "upgrade-assistant";
  version = "1.0.518";
  nugetHash = "sha256-VpesxikW1it/j/Wh4xj5Qj7mdfsgLljTuTJd2IzCHTk=";

  meta = {
    description = "Tool to assist developers in upgrading .NET Framework applications to .NET 6 and beyond";
    homepage = "https://github.com/dotnet/upgrade-assistant";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    platforms = lib.platforms.all;
    mainProgram = "ugprade-assistant";
  };
}
