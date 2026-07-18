{
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  callPackage,
  config,
}:

let
  buildFreshRssExtension = (callPackage ./freshrss-utils.nix { }).buildFreshRssExtension;

  official_extensions_version = "unstable-2025-12-26";
  official_extensions_src = fetchFromGitHub {
    hash = "sha256-El488QK3xWQM01GsuyBizud6VghXsRDqiOblnMfjVxE=";
    owner = "FreshRSS";
    repo = "Extensions";
    rev = "42c32bfd9af2d816933cf310e24d25888a8e167d";
  };

  baseExtensions =
    _self:
    lib.mapAttrs (_n: lib.recurseIntoAttrs) {
      auto-ttl = buildFreshRssExtension rec {
        pname = "auto-ttl";
        version = "0.5.0";

        src = fetchFromGitHub {
          owner = "mgnsk";
          repo = "FreshRSS-AutoTTL";
          rev = "v${version}";
          hash = "sha256-OiTiLZ2BjQD1W/BD8EkUt7WB2wOjL6GMGJ+APT4YpwE=";
        };

        FreshRssExtUniqueId = "AutoTTL";

        meta = {
          description = "FreshRSS extension for automatic feed refresh TTL based on the average frequency of entries";
          homepage = "https://github.com/mgnsk/FreshRSS-AutoTTL";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      demo = buildFreshRssExtension {
        pname = "demo";
        version = "unstable-2023-12-22";

        src = fetchFromGitHub {
          owner = "FreshRSS";
          repo = "xExtension-Demo";
          rev = "8d60f71a2f0411f5fbbb1f88a57791cee0848f35";
          hash = "sha256-5fe8TjefSiGMaeZkurxSJjX8qEEa1ArhJxDztp7ZNZc=";
        };

        FreshRssExtUniqueId = "Demo";

        meta = {
          description = "FreshRSS Extension for the demo version";
          homepage = "https://github.com/FreshRSS/xExtension-Demo";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      reading-time = buildFreshRssExtension {
        pname = "reading-time";
        version = "1.5";

        src = fetchFromGitLab {
          owner = "Lapineige";
          repo = "FreshRSS_Extension-ReadingTime";
          rev = "fb6e9e944ef6c5299fa56ffddbe04c41e5a34ebf";
          hash = "sha256-C5cRfaphx4Qz2xg2z+v5qRji8WVSIpvzMbethTdSqsk=";
          domain = "framagit.org";
        };

        FreshRssExtUniqueId = "ReadingTime";

        meta = {
          description = "FreshRSS extension adding a reading time estimation next to each article";
          homepage = "https://framagit.org/Lapineige/FreshRSS_Extension-ReadingTime";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      reddit-image = buildFreshRssExtension rec {
        pname = "reddit-image";
        version = "1.2.0";

        src = fetchFromGitHub {
          owner = "aledeg";
          repo = "xExtension-RedditImage";
          rev = "v${version}";
          hash = "sha256-H/uxt441ygLL0RoUdtTn9Q6Q/Ois8RHlhF8eLpTza4Q=";
        };

        FreshRssExtUniqueId = "RedditImage";

        meta = {
          description = "FreshRSS extension to process Reddit feeds";
          homepage = "https://github.com/aledeg/xExtension-RedditImage";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      title-wrap = buildFreshRssExtension {
        pname = "title-wrap";
        version = official_extensions_version;
        src = official_extensions_src;
        FreshRssExtUniqueId = "TitleWrap";
        sourceRoot = "${official_extensions_src.name}/xExtension-TitleWrap";

        meta = {
          description = "FreshRSS extension instead of truncating the title is wrapped";
          homepage = "https://github.com/FreshRSS/Extensions/tree/master/xExtension-TitleWrap";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      unsafe-auto-login = buildFreshRssExtension {
        pname = "unsafe-auto-login";
        version = official_extensions_version;
        src = official_extensions_src;
        FreshRssExtUniqueId = "UnsafeAutologin";
        sourceRoot = "${official_extensions_src.name}/xExtension-UnsafeAutologin";

        meta = {
          description = "FreshRSS extension to bring back unsafe autologin functionality.";
          homepage = "https://github.com/FreshRSS/Extensions/tree/master/xExtension-UnsafeAutologin";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };

      youtube = buildFreshRssExtension {
        pname = "youtube";
        version = official_extensions_version;
        src = official_extensions_src;
        FreshRssExtUniqueId = "YouTube";
        sourceRoot = "${official_extensions_src.name}/xExtension-YouTube";

        meta = {
          description = "FreshRSS extension allows you to directly watch YouTube/PeerTube videos from within subscribed channel feeds";
          homepage = "https://github.com/FreshRSS/Extensions/tree/master/xExtension-YouTube";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.stunkymonkey ];
        };
      };
    };

  # add possibility to define aliases
  aliases = super: {
    # example:  RedditImage = super.reddit-image;
  };

  # overlays will be applied left to right, overrides should come after aliases.
  overlays = lib.optionals config.allowAliases [
    (_self: super: lib.recursiveUpdate super (aliases super))
  ];

  toFix = lib.foldl' (lib.flip lib.extends) baseExtensions overlays;
in
(lib.fix toFix)
// {
  inherit buildFreshRssExtension;
}
