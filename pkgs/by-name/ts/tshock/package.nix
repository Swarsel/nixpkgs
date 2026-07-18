{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnet-runtime_9,
  dotnet-sdk_9,
  nix-update-script,
}:
buildDotnetModule rec {
  pname = "tshock";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "Pryaxis";
    repo = "TShock";
    rev = "v${version}";
    hash = "sha256-s6v/OUZmU0/kOH83N7xnurXdAtf49q/X69XWcKrKi/c=";
    fetchSubmodules = true;
  };

  doCheck = false; # The same.
  dotnet-runtime = dotnet-runtime_9;
  dotnet-sdk = dotnet-sdk_9;
  executables = [ "TShock.Server" ];
  nugetDeps = ./deps.json;
  nugetSource = "https://api.nuget.org/v3/index.json";

  projectFile = [
    "TShockAPI/TShockAPI.csproj"
    "TerrariaServerAPI/TerrariaServerAPI/TerrariaServerAPI.csproj"
    "TShockLauncher/TShockLauncher.csproj"
    "TShockInstaller/TShockInstaller.csproj"
    "TShockPluginManager/TShockPluginManager.csproj"
  ]; # Excluding tests because they can't build for some reason

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modded server software for Terraria, providing a plugin system and inbuilt tools such as anti-cheat, server-side characters, groups, permissions, and item bans";
    homepage = "https://github.com/Pryaxis/TShock";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.proggerx ];
    mainProgram = "TShock.Server";
  };
}
