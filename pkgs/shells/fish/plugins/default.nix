{
  lib,
  config,
  newScope,
}:

lib.makeScope newScope (
  self:
  with self;
  {
    ai = callPackage ./ai.nix { };
    async-prompt = callPackage ./async-prompt.nix { };
    autopair = callPackage ./autopair.nix { };
    aws = callPackage ./aws.nix { };
    bang-bang = callPackage ./bang-bang.nix { };
    bass = callPackage ./bass.nix { };
    bobthefish = callPackage ./bobthefish.nix { };
    bobthefisher = callPackage ./bobthefisher.nix { };
    buildFishPlugin = callPackage ./build-fish-plugin.nix { };
    clownfish = callPackage ./clownfish.nix { };
    colored-man-pages = callPackage ./colored-man-pages.nix { };
    done = callPackage ./done.nix { };
    exercism-cli-fish-wrapper = callPackage ./exercism-cli-fish-wrapper.nix { };
    fifc = callPackage ./fifc.nix { };
    fish-bd = callPackage ./fish-bd.nix { };
    fish-you-should-use = callPackage ./fish-you-should-use.nix { };
    fishbang = callPackage ./fishbang.nix { };
    # Fishtape 2.x and 3.x aren't compatible,
    # but both versions are used in the tests of different other plugins.
    fishtape = callPackage ./fishtape.nix { };
    fishtape_3 = callPackage ./fishtape_3.nix { };
    foreign-env = callPackage ./foreign-env { };
    forgit = callPackage ./forgit.nix { };
    fzf = callPackage ./fzf.nix { };
    fzf-fish = callPackage ./fzf-fish.nix { };
    git-abbr = callPackage ./git-abbr.nix { };
    github-copilot-cli-fish = callPackage ./github-copilot-cli-fish.nix { };
    grc = callPackage ./grc.nix { };
    gruvbox = callPackage ./gruvbox.nix { };
    humantime-fish = callPackage ./humantime-fish.nix { };
    hydro = callPackage ./hydro.nix { };
    macos = callPackage ./macos.nix { };
    nvm = callPackage ./nvm.nix { };
    pisces = callPackage ./pisces.nix { };
    plugin-git = callPackage ./plugin-git.nix { };
    plugin-sudope = callPackage ./plugin-sudope.nix { };
    puffer = callPackage ./puffer.nix { };
    pure = callPackage ./pure.nix { };
    sdkman-for-fish = callPackage ./sdkman-for-fish.nix { };
    spark = callPackage ./spark.nix { };
    sponge = callPackage ./sponge.nix { };
    tide = callPackage ./tide.nix { };
    transient-fish = callPackage ./transient-fish.nix { };
    wakatime-fish = callPackage ./wakatime-fish.nix { };
    z = callPackage ./z.nix { };
  }
  // lib.optionalAttrs config.allowAliases {
    autopair-fish = self.autopair; # Added 2023-03-10
  }
)
