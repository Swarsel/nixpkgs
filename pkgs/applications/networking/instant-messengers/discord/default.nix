{
  lib,
  stdenv,
  callPackage,
  discord,
  discord-canary,
  discord-development,
  discord-ptb,
}:
let
  variants = rec {
    aarch64-darwin = {
      discord = rec {
        binaryName = desktopName;
        branch = "stable";
        desktopName = "Discord";
        self = discord;
      };

      discord-canary = rec {
        binaryName = desktopName;
        branch = "canary";
        desktopName = "Discord Canary";
        self = discord-canary;
      };

      discord-development = rec {
        binaryName = desktopName;
        branch = "development";
        desktopName = "Discord Development";
        self = discord-development;
      };

      discord-ptb = rec {
        binaryName = desktopName;
        branch = "ptb";
        desktopName = "Discord PTB";
        self = discord-ptb;
      };
    };

    default = x86_64-linux; # Used for unsupported platforms, so we can return *something* there.

    x86_64-linux = {
      discord = rec {
        binaryName = desktopName;
        branch = "stable";
        desktopName = "Discord";
        self = discord;
      };

      discord-canary = {
        binaryName = "DiscordCanary";
        branch = "canary";
        desktopName = "Discord Canary";
        self = discord-canary;
      };

      discord-development = {
        binaryName = "DiscordDevelopment";
        branch = "development";
        desktopName = "Discord Development";
        self = discord-development;
      };

      discord-ptb = {
        binaryName = "DiscordPTB";
        branch = "ptb";
        desktopName = "Discord PTB";
        self = discord-ptb;
      };
    };
  };

  meta = {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      artturin
      _4evy
      infinidoge
      jopejoe1
      Scrumplex
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "discord";
    downloadPage = "https://discordapp.com/download";
  };
  package = if stdenv.hostPlatform.isLinux then ./linux.nix else ./darwin.nix;

  sources = lib.importJSON ./sources.json;
in
lib.genAttrs [ "discord" "discord-ptb" "discord-canary" "discord-development" ] (
  pname:
  let
    args = (variants.${stdenv.hostPlatform.system} or variants.default).${pname};
    platformName = if stdenv.hostPlatform.isDarwin then "osx" else "linux";
    source = sources."${platformName}-${args.branch}";
  in
  callPackage package (
    args
    // {
      inherit pname source;

      meta = meta // {
        mainProgram = args.binaryName;
      };
    }
  )
)
