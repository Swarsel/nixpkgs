{
  lib,
  stdenv,
  fetchFromGitHub,
  config,
  nix-update-script,
  pkgs,
}:

let
  rtpPath = "share/tmux-plugins";

  addRtp =
    path: rtpFilePath: attrs: derivation:
    derivation
    // {
      rtp = "${derivation}/${path}/${rtpFilePath}";
    }
    // {
      overrideAttrs = f: mkTmuxPlugin (attrs // (if lib.isFunction f then f attrs else f));
    };

  mkTmuxPlugin =
    a@{
      pluginName,
      src,
      addonInfo ? null,
      buildPhase ? ":",
      configurePhase ? ":",
      namePrefix ? "tmuxplugin-",
      path ? lib.getName pluginName,
      postInstall ? "",
      preInstall ? "",
      rtpFilePath ? (builtins.replaceStrings [ "-" ] [ "_" ] pluginName) + ".tmux",
      unpackPhase ? "",
      ...
    }:
    if lib.hasAttr "dependencies" a then
      throw "dependencies attribute is obselete. see NixOS/nixpkgs#118034" # added 2021-04-01
    else
      addRtp "${rtpPath}/${path}" rtpFilePath a (
        stdenv.mkDerivation (
          a
          // {
            inherit
              pluginName
              unpackPhase
              configurePhase
              buildPhase
              addonInfo
              preInstall
              postInstall
              ;

            pname = namePrefix + pluginName;
            strictDeps = true;

            installPhase = ''
              runHook preInstall

              target=$out/${rtpPath}/${path}
              mkdir -p $out/${rtpPath}
              cp -r . $target
              if [ -n "$addonInfo" ]; then
                echo "$addonInfo" > $target/addon-info.json
              fi

              runHook postInstall
            '';

            __structuredAttrs = true;
            passthru.updateScript = nix-update-script { };
          }
        )
      );

in
{
  inherit mkTmuxPlugin;

  battery = mkTmuxPlugin rec {
    version = "2.0.0";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-battery";
      tag = "v${version}";
      hash = "sha256-kyUrJdraDDye8WEBP2RgHN7kHmafToYtLmrMJ9u0f+0=";
    };

    pluginName = "battery";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-battery";
    };
  };

  better-mouse-mode = mkTmuxPlugin {
    version = "unstable-2021-08-02";

    src = fetchFromGitHub {
      owner = "NHDaly";
      repo = "tmux-better-mouse-mode";
      rev = "aa59077c635ab21b251bd8cb4dc24c415e64a58e";
      hash = "sha256-nPNa3JvDgptGvy2vpo0WSZytyu7kFSEn/Jp/OGA0ZBg=";
    };

    pluginName = "better-mouse-mode";
    rtpFilePath = "scroll_copy_mode.tmux";

    meta = {
      description = "Better mouse support for tmux";

      longDescription = ''
        Features:

          * Emulate mouse-support for full-screen programs like less that don't provide built in mouse support.
          * Exit copy-mode and return to your prompt by scrolling back all the way down to the bottom.
          * Adjust your scrolling speed.
      '';

      homepage = "https://github.com/NHDaly/tmux-better-mouse-mode";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ chrispickard ];
      platforms = lib.platforms.unix;
    };
  };

  catppuccin = mkTmuxPlugin rec {
    version = "2.1.3";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "v${version}";
      hash = "sha256-Is0CQ1ZJMXIwpDjrI5MDNHJtq+R3jlNcd9NXQESUe2w=";
    };

    postInstall = ''
      sed -i -e 's|''${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme|''${TMUX_TMPDIR}/catppuccin-selected-theme.tmuxtheme|g' $target/catppuccin.tmux
    '';

    pluginName = "catppuccin";

    meta = {
      description = "Soothing pastel theme for Tmux";
      homepage = "https://github.com/catppuccin/tmux";
      license = lib.licenses.mit;
      maintainers = [ ];
      platforms = lib.platforms.unix;
    };
  };

  continuum = mkTmuxPlugin {
    version = "unstable-2022-01-25";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-continuum";
      rev = "fc2f31d79537a5b349f55b74c8ca69abaac1ddbb";
      hash = "sha256-S1YuZHX4SnSVlMZKv/a87/qj0seRdaWyOXz5ONCVIRo=";
    };

    pluginName = "continuum";

    meta = {
      description = "Continuous saving of tmux environment";

      longDescription = ''
        Features:
        * continuous saving of tmux environment
        * automatic tmux start when computer/server is turned on
        * automatic restore when tmux is started

        Together, these features enable uninterrupted tmux usage. No matter the
        computer or server restarts, if the machine is on, tmux will be there how
        you left it off the last time it was used.
      '';

      homepage = "https://github.com/tmux-plugins/tmux-continuum";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ronanmacf ];
      platforms = lib.platforms.unix;
    };
  };

  copy-toolkit = mkTmuxPlugin {
    version = "2021-12-20";

    src = fetchFromGitHub {
      owner = "CrispyConductor";
      repo = "tmux-copy-toolkit";
      rev = "c80c2c068059fe04f840ea9f125c21b83cb6f81f";
      hash = "sha256-cLeOoJ+4MF8lSpwy5lkcPakvB3cpgey0RfLbVTwERNk=";
    };

    postInstall = ''
      sed -i -e 's|python3 |${pkgs.python3}/bin/python3 |g' $target/copytk.tmux
      sed -i -e 's|python3|${pkgs.python3}/bin/python3|g;s|/bin/bash|${pkgs.bash}/bin/bash|g;s|/bin/cat|${pkgs.coreutils}/bin/cat|g' $target/copytk.py
    '';

    pluginName = "copy-toolkit";
    rtpFilePath = "copytk.tmux";

    meta = {
      description = "Various copy-mode tools";
      homepage = "https://github.com/CrispyConductor/tmux-copy-toolkit";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        deejayem
        sedlund
      ];

      platforms = lib.platforms.unix;
    };
  };

  copycat = mkTmuxPlugin {
    version = "unstable-2020-01-09";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-copycat";
      rev = "77ca3aab2aed8ede3e2b941079b1c92dd221cf5f";
      hash = "sha256-ugVk1zpKeUjOlDWi3LEkJPFsCqyZEivGzGWiqODnkK0=";
    };

    pluginName = "copycat";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-copycat";
    };
  };

  cpu = mkTmuxPlugin {
    version = "unstable-2023-01-06";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-cpu";
      rev = "98d787191bc3e8f19c3de54b96ba1caf61385861";
      hash = "sha256-ymmCI6VYvf94Ot7h2GAboTRBXPIREP+EB33+px5aaJk=";
    };

    pluginName = "cpu";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-cpu";
    };
  };

  ctrlw = mkTmuxPlugin rec {
    version = "0.1.1";

    src = fetchFromGitHub {
      owner = "eraserhd";
      repo = "tmux-ctrlw";
      rev = "v${version}";
      hash = "sha256-YYbPkGQmukIDD1fcYleioETFai/SOJni+aZ9Jh2+Zc8=";
    };

    pluginName = "ctrlw";

    meta = {
      homepage = "https://github.com/eraserhd/tmux-ctrlw";
    };
  };

  dotbar = mkTmuxPlugin rec {
    version = "0.3.3";

    src = fetchFromGitHub {
      owner = "vaaleyard";
      repo = "tmux-dotbar";
      tag = version;
      hash = "sha256-CAKEN8Sk3t0nonV2R9df/DFTTUrVnbso0ZVGgeeGINM=";
    };

    pluginName = "dotbar";

    meta = {
      description = "Simple and minimalist status bar for tmux";
      homepage = "https://github.com/vaaleyard/tmux-dotbar";
      changelog = "https://github.com/vaaleyard/tmux-dotbar/releases/tag/${version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ FKouhai ];
      platforms = lib.platforms.unix;
      downloadPage = "https://github.com/vaaleyard/tmux-dotbar";
    };
  };

  dracula = mkTmuxPlugin rec {
    version = "3.3.1";

    src = fetchFromGitHub {
      owner = "dracula";
      repo = "tmux";
      tag = "v${version}";
      hash = "sha256-UFK0PJFgGIBdpjuSn3stAJ7z73FgEj0yK6F+ETRQ5f4=";
    };

    pluginName = "dracula";

    meta = {
      description = "Feature packed Dracula theme for tmux";
      homepage = "https://draculatheme.com/tmux";
      changelog = "https://github.com/dracula/tmux/releases/tag/v${version}/CHANGELOG.md";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ethancedwards8 ];
      platforms = lib.platforms.unix;
      downloadPage = "https://github.com/dracula/tmux";
    };
  };

  extrakto = mkTmuxPlugin {
    version = "0-unstable-2025-07-27";

    src = fetchFromGitHub {
      owner = "laktak";
      repo = "extrakto";
      rev = "b04dcf14496ffda629d8aa3a2ac63e4e08d2fdc9";
      hash = "sha256-lknfek9Fu/RDHbq5HMaiNqc24deni5phzExWOkYRS+o";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.python3 ];

    postInstall = ''
      patchShebangs extrakto.py extrakto_plugin.py

       wrapProgram $target/scripts/open.sh \
         --prefix PATH : ${
           with pkgs;
           lib.makeBinPath (
             [ fzf ]
             ++ lib.optionals stdenv.hostPlatform.isLinux [
               xclip
               wl-clipboard
             ]
           )
         }
    '';

    pluginName = "extrakto";

    meta = {
      description = "Fuzzy find your text with fzf instead of selecting it by hand ";
      homepage = "https://github.com/laktak/extrakto";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        kidd
        fnune
        deejayem
      ];

      platforms = lib.platforms.unix;
    };
  };

  fingers = pkgs.callPackage ./tmux-fingers {
    inherit mkTmuxPlugin;
  };

  fpp = mkTmuxPlugin {
    version = "unstable-2016-03-08";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-fpp";
      rev = "ca125d5a9c80bb156ac114ac3f3d5951a795c80e";
      hash = "sha256-mhf1PPlo7AaAx7haRDgS+LYW7eFCOB6LPtHF76rRCa0=";
    };

    postInstall = ''
      sed -i -e 's|fpp |${pkgs.fpp}/bin/fpp |g' $target/fpp.tmux
    '';

    pluginName = "fpp";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-fpp";
    };
  };

  fuzzback = mkTmuxPlugin {
    version = "unstable-2022-11-21";

    src = fetchFromGitHub {
      owner = "roosta";
      repo = "tmux-fuzzback";
      rev = "bfd9cf0ef1c35488f0080f0c5ca4fddfdd7e18ec";
      hash = "sha256-w788xDBkfiLdUVv1oJi0YikFPqVk6LiN6PDfHu8on5E=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      for f in fuzzback.sh preview.sh supported.sh; do
        chmod +x $target/scripts/$f
        wrapProgram $target/scripts/$f \
          --prefix PATH : ${
            with pkgs;
            lib.makeBinPath [
              coreutils
              fzf
              gawk
              gnused
            ]
          }
      done
    '';

    pluginName = "fuzzback";

    meta = {
      description = "Fuzzy search for terminal scrollback";
      homepage = "https://github.com/roosta/tmux-fuzzback";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ deejayem ];
      platforms = lib.platforms.unix;
    };
  };

  fzf-tmux-url = mkTmuxPlugin {
    version = "unstable-2024-04-14";

    src = fetchFromGitHub {
      owner = "wfxr";
      repo = "tmux-fzf-url";
      rev = "28ed7ce3c73a328d8463d4f4aaa6ccb851e520fa";
      hash = "sha256-tl0SjG/CeolrN7OIHj6MgkB9lFmFgEuJevsSuwVs+78=";
    };

    pluginName = "fzf-tmux-url";
    rtpFilePath = "fzf-url.tmux";

    meta = {
      description = "Quickly open urls on your terminal screen";
      homepage = "https://github.com/wfxr/tmux-fzf-url";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };

  gruvbox = mkTmuxPlugin rec {
    version = "2.0.1";

    src = fetchFromGitHub {
      owner = "egel";
      repo = "tmux-gruvbox";
      tag = "v${version}";
      hash = "sha256-TuWPw6sk61k7GnHwN2zH6x6mGurTHiA9f0E6NJfMa6g=";
    };

    pluginName = "gruvbox";
    rtpFilePath = "gruvbox-tpm.tmux";

    meta = {
      description = "Gruvbox colorscheme for Tmux";
      homepage = "https://github.com/egel/tmux-gruvbox";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ viena ];
      platforms = lib.platforms.unix;
    };
  };

  harpoon = mkTmuxPlugin {
    version = "0.5.0";

    src = fetchFromGitHub {
      owner = "chaitanyabsprip";
      repo = "tmux-harpoon";
      rev = "v0.5.0";
      hash = "sha256-eqzf3hEaliF1t7zwZlj1YDGvn0jKdbBTgy5PoOPVMEU=";
    };

    pluginName = "harpoon";
    rtpFilePath = "harpoon.tmux";

    meta = {
      description = "Tool to bookmark session supporting auto create for sessions";
      homepage = "https://github.com/Chaitanyabsprip/tmux-harpoon";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ FKouhai ];
      platforms = lib.platforms.unix;
      downloadPage = "https://github.com/Chaitanyabsprip/tmux-harpoon";
    };
  };

  jump = mkTmuxPlugin {
    version = "2020-06-26";

    src = fetchFromGitHub {
      owner = "schasse";
      repo = "tmux-jump";
      rev = "416f613d3eaadbe1f6f9eda77c49430527ebaffb";
      hash = "sha256-XxdQtJPkTTCbaGUw4ebtzPQq+QuJOOSAjQKrp6Fvf/U=";
    };

    postInstall = ''
      sed -i -e 's|ruby|${pkgs.ruby}/bin/ruby|g' $target/scripts/tmux-jump.sh
    '';

    pluginName = "jump";
    rtpFilePath = "tmux-jump.tmux";

    meta = {
      description = "Vimium/Easymotion like navigation for tmux";
      homepage = "https://github.com/schasse/tmux-jump";
      license = lib.licenses.gpl3;
      maintainers = with lib.maintainers; [ arnarg ];
      platforms = lib.platforms.unix;
    };
  };

  lazy-restore = mkTmuxPlugin rec {
    version = "0.1.2";

    src = fetchFromGitHub {
      owner = "bcampolo";
      repo = "tmux-lazy-restore";
      tag = "v${version}";
      hash = "sha256-LLXGXJzIB2I0NMbWTh2DtLTAyC+JMzNM//SbKtFd9nM=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      for f in LICENSE README.md; do
        rm -rf $target/$f
      done
      wrapProgram $target/scripts/tmux-session-manager.sh \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            coreutils
            findutils
            fzf
            gnused
            jq
            tmux
          ]
        }
    '';

    pluginName = "lazy-restore";
    rtpFilePath = "tmux-lazy-restore.tmux";

    meta = {
      description = "session manager plugin that allows sessions to be lazily restored in order to save memory and processing power";
      homepage = "https://github.com/bcampolo/tmux-lazy-restore";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ bbigras ];
      platforms = lib.platforms.unix;
    };
  };

  logging = mkTmuxPlugin {
    version = "unstable-2019-04-19";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-logging";
      rev = "b085ad423b5d59a2c8b8d71772352e7028b8e1d0";
      hash = "sha256-Wp4xY2nxv4jl/G7bjNokYk3TcbS9waLERBFSpT1XGlw=";
    };

    pluginName = "logging";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-logging";
    };
  };

  maildir-counter = mkTmuxPlugin {
    version = "unstable-2016-11-25";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-maildir-counter";
      rev = "9415f0207e71e37cbd870c9443426dbea6da78b9";
      hash = "sha256-RFdnF/ScOPoeVgGXWhQs28tS7CmsRA0DyFyutCPEmzc=";
    };

    pluginName = "maildir-counter";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-maildir-counter";
    };
  };

  minimal-tmux-status = mkTmuxPlugin {
    version = "0-unstable-2025-06-04";

    src = fetchFromGitHub {
      owner = "semi710";
      repo = "minimal-tmux-status";
      rev = "de2bb049a743e0f05c08531a0461f7f81da0fc72";
      hash = "sha256-0gXtFVan+Urb79AjFOjHdjl3Q73m8M3wFSo3ZhjxcBA=";
    };

    pluginName = "minimal-tmux-status";
    rtpFilePath = "minimal.tmux";

    meta = {
      description = "Minimal tmux status line plugin with prefix key indicator";

      longDescription = ''
        minimal-tmux-status is a lightweight plugin for tmux that provides a simple, customizable status line.
        In addition to basic session info, it shows whether the tmux prefix key is currently pressed, helping users
        quickly identify the prefix state. Designed to be minimal in appearance and dependencies, it is ideal for users
        who want essential information without clutter.
      '';

      homepage = "https://github.com/semi710/minimal-tmux-status.git";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        semi710
      ];

      platforms = lib.platforms.unix;
    };
  };

  mode-indicator = mkTmuxPlugin {
    version = "unstable-2021-10-01";

    src = fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "tmux-mode-indicator";
      rev = "11520829210a34dc9c7e5be9dead152eaf3a4423";
      hash = "sha256-hlhBKC6UzkpUrCanJehs2FxK5SoYBoiGiioXdx6trC4=";
    };

    pluginName = "mode-indicator";

    meta = {
      description = "Plugin that displays prompt indicating currently active Tmux mode";
      homepage = "https://github.com/MunifTanjim/tmux-mode-indicator";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ aacebedo ];
      platforms = lib.platforms.unix;
    };
  };

  net-speed = mkTmuxPlugin {
    version = "unstable-2018-12-02";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-net-speed";
      rev = "58abb615971cb617821e2e7e41c660334f55a92d";
      hash = "sha256-LFPcPDBiSvsOhOhlAScajr/Y/Uw2CPdl87qzD9szQKo=";
    };

    pluginName = "net-speed";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-net-speed";
    };
  };

  nord = mkTmuxPlugin {
    version = "0.3.0-unstable-2023-03-03";

    src = pkgs.fetchFromGitHub {
      owner = "nordtheme";
      repo = "tmux";
      rev = "f7b6da07ab55fe32ee5f7d62da56d8e5ac691a92";
      hash = "sha256-mcmVYNWOUoQLiu4eM/EUudRg67Gcou13xuC6zv9aMKA=";
    };

    pluginName = "nord";

    meta = {
      description = "Nord Tmux theme with plugin support";

      longDescription = ''
        > An arctic, north-bluish clean and elegant tmux theme.
        > Designed for a fluent and clear workflow with support for third-party plugins.

        This plugin requires that tmux be used with a Nord terminal emulator
        theme in order to work properly.
      '';

      homepage = "https://www.nordtheme.com/ports/tmux";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.sigmasquadron ];
    };
  };

  onedark-theme = mkTmuxPlugin {
    version = "unstable-2020-06-07";

    src = fetchFromGitHub {
      owner = "odedlaz";
      repo = "tmux-onedark-theme";
      rev = "3607ef889a47dd3b4b31f66cda7f36da6f81b85c";
      hash = "sha256-pQooiDEeB8NvBOQ1IKUgPSSQDK+hMTLMGuiKy6GWVKY=";
    };

    pluginName = "onedark-theme";
    rtpFilePath = "tmux-onedark-theme.tmux";

    meta = {
      homepage = "https://github.com/odedlaz/tmux-onedark-theme";
    };
  };

  online-status = mkTmuxPlugin {
    version = "unstable-2018-11-30";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-online-status";
      rev = "ea86704ced8a20f4a431116aa43f57edcf5a6312";
      hash = "sha256-OQW2WcNDVBMgX5IIlykn7f1wI8miXuqLQTlqsdHbw8M=";
    };

    pluginName = "online-status";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-online-status";
    };
  };

  open = mkTmuxPlugin {
    version = "unstable-2019-12-02";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-open";
      rev = "cedb4584908bd8458fadc8d3e64101d3cbb48d46";
      hash = "sha256-sFl+wkvQ498irwKWXXAT6/XBrziYLT+CvLCBV2HrQIM=";
    };

    pluginName = "open";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-open";
    };
  };

  pain-control = mkTmuxPlugin {
    version = "unstable-2020-02-18";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-pain-control";
      rev = "2db63de3b08fc64831d833240749133cecb67d92";
      hash = "sha256-84NJtxoz4KTVv+i3cde235WcHhRSBIkZjtobZIk16nA=";
    };

    pluginName = "pain-control";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-pain-control";
    };
  };

  pass = mkTmuxPlugin {
    version = "0-unstable-2025-02-20";

    src = fetchFromGitHub {
      owner = "rafi";
      repo = "tmux-pass";
      rev = "c853c8b5e31dea93d17551ef3e18be16c063e28e";
      hash = "sha256-fDAqQcr0SC9WrKbGgt7z03ex2ORZ7ChOzDGl6HFXMaA";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      rm $target/README.md
      rm -r $target/test

      wrapProgram $target/scripts/main.sh \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            findutils
            fzf
            gnugrep
            gnused
            ncurses
            pkgs.pass
            tmux
          ]
        }
    '';

    pluginName = "pass";
    rtpFilePath = "plugin.tmux";

    meta = {
      description = "Password-store browser using fzf in tmux";
      homepage = "https://github.com/rafi/tmux-pass";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.ethancedwards8 ];
    };
  };

  plumb = mkTmuxPlugin rec {
    version = "0.1.1";

    src = fetchFromGitHub {
      owner = "eraserhd";
      repo = "tmux-plumb";
      rev = "v${version}";
      hash = "sha256-WcTyAeuGAF+Xsqeb3MtRtHDSXiUmTJNDQOkrQJsj07A=";
    };

    postInstall = ''
      sed -i -e 's,9 plumb,${pkgs.plan9port}/bin/9 plumb,' $target/scripts/plumb
    '';

    pluginName = "plumb";

    meta = {
      homepage = "https://github.com/eraserhd/tmux-plumb";
    };
  };

  power-theme = mkTmuxPlugin {
    version = "unstable-2024-05-12";

    src = pkgs.fetchFromGitHub {
      owner = "wfxr";
      repo = "tmux-power";
      rev = "16bbde801378a70512059541d104c5ae35be32b9";
      hash = "sha256-IyYQyIONMnVBwhhcI3anOPxKpv2TfI2KZgJ5o5JtZ8I=";
    };

    pluginName = "power";
    rtpFilePath = "tmux-power.tmux";

    meta = {
      description = "Tmux powerline theme";
      homepage = "https://github.com/wfxr/tmux-power";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };

  prefix-highlight = mkTmuxPlugin {
    version = "unstable-2021-03-30";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-prefix-highlight";
      rev = "15acc6172300bc2eb13c81718dc53da6ae69de4f";
      hash = "sha256-9LWRV0Hw8MmDwn5hWl3DrBuYUqBjLCO02K9bbx11MyM=";
    };

    pluginName = "prefix-highlight";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-prefix-highlight";
    };
  };

  resurrect = mkTmuxPlugin {
    version = "unstable-2022-05-01";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "ca6468e2deef11efadfe3a62832ae67742505432";
      hash = "sha256-wl9/5XvFq+AjV8CwYgIZjPOE0/kIuEYBNQqNDidjNFo=";
      fetchSubmodules = true;
    };

    pluginName = "resurrect";

    meta = {
      description = "Restore tmux environment after system restart";

      longDescription = ''
        This plugin goes to great lengths to save and restore all the details
        from your tmux environment. Here's what's been taken care of:

        * all sessions, windows, panes and their order
        * current working directory for each pane
        * exact pane layouts within windows (even when zoomed)
        * active and alternative session
        * active and alternative window for each session
        * windows with focus
        * active pane for each window
        * "grouped sessions" (useful feature when using tmux with multiple monitors)
        * programs running within a pane! More details in the restoring programs doc.

        Optional:
        * restoring vim and neovim sessions
        * restoring pane contents
      '';

      homepage = "https://github.com/tmux-plugins/tmux-resurrect";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ronanmacf ];
      platforms = lib.platforms.unix;
    };
  };

  rose-pine = mkTmuxPlugin {
    version = "unstable-2024-01-08";

    src = fetchFromGitHub {
      owner = "rose-pine";
      repo = "tmux";
      rev = "dd6d01338ac4afeb96542dcf24e4a7fe179b69e6";
      hash = "sha256-Tccb4VjdotOSw7flJV4N0H4557NxRhXiCecZBPU9ICQ=";
    };

    pluginName = "rose-pine";
    rtpFilePath = "rose-pine.tmux";

    meta = {
      description = "Rosé Pine theme for tmux";
      homepage = "https://github.com/rose-pine/tmux";
      license = lib.licenses.mit;
    };
  };

  search-panes = mkTmuxPlugin {
    version = "0-unstable-2025-07-27";

    src = fetchFromGitHub {
      owner = "multi-io";
      repo = "tmux-search-panes";
      rev = "3996b5c56c6be69d3a85ef26065b1877d9ac71c6";
      hash = "sha256-Z9Gu4v2LAyG6UxXVLTvQUz1wU4PaJlBQXjLiSzfSP7s=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      for f in search-panes.sh _fzf-and-switch.sh _render-preview.sh; do
        chmod +x $target/bin/$f
        wrapProgram $target/bin/$f \
          --prefix PATH : ${
            with pkgs;
            lib.makeBinPath [
              coreutils
              fzf
              gnugrep
              gnused
              tmux
            ]
          }
      done
    '';

    pluginName = "search-panes";
    rtpFilePath = "tmux-search-panes.tmux";

    meta = {
      description = "Tmux plugin that allows you to perform a fulltext search";
      homepage = "https://github.com/multi-io/tmux-search-panes";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.DieracDelta ];
      platforms = lib.platforms.unix;
    };
  };

  sensible = mkTmuxPlugin {
    version = "unstable-2022-08-14";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sensible";
      rev = "25cb91f42d020f675bb0a2ce3fbd3a5d96119efa";
      hash = "sha256-sw9g1Yzmv2fdZFLJSGhx1tatQ+TtjDYNZI5uny0+5Hg=";
    };

    postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
      sed -e 's:reattach-to-user-namespace:${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace:g' -i $target/sensible.tmux
    '';

    pluginName = "sensible";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-sensible";
    };
  };

  session-wizard = mkTmuxPlugin rec {
    version = "1.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "27medkamal";
      repo = "tmux-session-wizard";
      rev = "V${version}";
      hash = "sha256-mLpZQSo8nildawsPxGwkcETNwlRq6O1pfy/VusMNMaw=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      for f in .gitignore Dockerfile flake.* scripts tests; do
        rm -rf $target/$f
      done
      substituteInPlace $target/session-wizard.tmux --replace  \$CURRENT_DIR $target
      wrapProgram $target/bin/t \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            fzf
            zoxide
            coreutils
            gnugrep
            gnused
          ]
        }
    '';

    pluginName = "session-wizard";
    rtpFilePath = "session-wizard.tmux";

    meta = {
      description = "Tmux plugin for creating and switching between sessions based on recently accessed directories";

      longDescription = ''
        Session Wizard is using fzf and zoxide to do all the magic. Features:
        * Creating a new session from a list of recently accessed directories
        * Naming a session after a folder/project
        * Switching sessions
        * Viewing current or creating new sessions in one popup
      '';

      homepage = "https://github.com/27medkamal/tmux-session-wizard";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ mandos ];
      platforms = lib.platforms.unix;
    };
  };

  sessionist = mkTmuxPlugin {
    version = "unstable-2023-05-02";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sessionist";
      rev = "a315c423328d9bdf5cf796435ce7075fa5e1bffb";
      hash = "sha256-iC8NvuLujTXw4yZBaenHJ+2uM+HA9aW5b2rQTA8e69s=";
    };

    pluginName = "sessionist";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-sessionist";
    };
  };

  sidebar = mkTmuxPlugin {
    version = "unstable-2018-11-30";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sidebar";
      rev = "aacbdb45bc5ab69db448a72de4155d0b8dbac677";
      hash = "sha256-7MCouewjpTCMGmWMaTWWQevlR0LrLTBjXGumsNcH6a4=";
    };

    pluginName = "sidebar";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-sidebar";
    };
  };

  sysstat = mkTmuxPlugin {
    version = "unstable-2017-12-12";

    src = fetchFromGitHub {
      owner = "samoshkin";
      repo = "tmux-plugin-sysstat";
      rev = "29e150f403151f2341f3abcb2b2487a5f011dd23";
      hash = "sha256-2EMSV6z9FZHq20dkPna0qELSVIOIAnOHpiCLbG7adQQ=";
    };

    pluginName = "sysstat";

    meta = {
      homepage = "https://github.com/samoshkin/tmux-plugin-sysstat";
    };
  };

  t-smart-tmux-session-manager = mkTmuxPlugin rec {
    version = "2.11.1";

    src = pkgs.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "t-smart-tmux-session-manager";
      rev = "v${version}";
      hash = "sha256-iEiTF4NPUCVDp+bIfrbRx8HE1NrTJtxd667fTk0EfEA=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      wrapProgram $target/bin/t \
          --prefix PATH : ${

            lib.makeBinPath [
              pkgs.fzf
              pkgs.zoxide
            ]
          }

      find $target -type f -print0 | xargs -0 sed -i -e 's|fzf |${pkgs.fzf}/bin/fzf |g'
      find $target -type f -print0 | xargs -0 sed -i -e 's|zoxide |${pkgs.zoxide}/bin/zoxide |g'
    '';

    pluginName = "t-smart-tmux-session-manager";
    rtpFilePath = "t-smart-tmux-session-manager.tmux";

    meta = {
      homepage = "https://github.com/joshmedeski/t-smart-tmux-session-manager";
    };
  };

  tilish = mkTmuxPlugin {
    version = "unstable-2023-09-20";

    src = fetchFromGitHub {
      owner = "jabirali";
      repo = "tmux-tilish";
      rev = "22f7920837d827dc6cb31143ea916afa677c24c1";
      hash = "sha256-wP3c+p/DM6ve7GUhi0QEzggct7NS4XUa78sVQFSKrfo=";
    };

    pluginName = "tilish";

    meta = {
      description = "Plugin which makes tmux work and feel like i3wm";
      homepage = "https://github.com/jabirali/tmux-tilish";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ arnarg ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-colors-solarized = mkTmuxPlugin {
    version = "unstable-2019-07-14";

    src = fetchFromGitHub {
      owner = "seebi";
      repo = "tmux-colors-solarized";
      rev = "e5e7b4f1af37f8f3fc81ca17eadee5ae5d82cd09";
      hash = "sha256-nVA4fkmxf8he3lxG6P0sASvH6HlSt8dKGovEv5RAcdA=";
    };

    pluginName = "tmuxcolors";

    meta = {
      homepage = "https://github.com/seebi/tmux-colors-solarized";
    };
  };

  tmux-floax = mkTmuxPlugin {
    version = "0-unstable-2024-07-24";

    src = fetchFromGitHub {
      owner = "omerxx";
      repo = "tmux-floax";
      rev = "46c0a6a8c3cf79b83d1b338f547acbbd1d306301";
      hash = "sha256-bALZfVWcoAzcTeWwkBHhi7TzUQJicOBTNdeJh3O/Bj8=";
    };

    pluginName = "tmux-floax";
    rtpFilePath = "floax.tmux";

    meta = {
      description = "Floating pane for Tmux";
      homepage = "https://github.com/omerxx/tmux-floax";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ redyf ];
      platforms = lib.platforms.all;
      mainProgram = "tmux-floax";
    };
  };

  tmux-fzf = mkTmuxPlugin {
    version = "unstable-2023-10-24";

    src = fetchFromGitHub {
      owner = "sainnhe";
      repo = "tmux-fzf";
      rev = "d62b6865c0e7c956ad1f0396823a6f34cf7452a7";
      hash = "sha256-hVkSQYvBXrkXbKc98V9hwwvFp6z7/mX1K4N3N9j4NN4=";
    };

    postInstall = ''
      find $target -type f -print0 | xargs -0 sed -i -e 's|fzf |${pkgs.fzf}/bin/fzf |g'
      find $target -type f -print0 | xargs -0 sed -i -e 's|sed |${pkgs.gnused}/bin/sed |g'
      find $target -type f -print0 | xargs -0 sed -i -e 's|tput |${pkgs.ncurses}/bin/tput |g'
    '';

    pluginName = "tmux-fzf";
    rtpFilePath = "main.tmux";

    meta = {
      description = "Use fzf to manage your tmux work environment! ";

      longDescription = ''
        Features:
        * Manage sessions (attach, detach*, rename, kill*).
        * Manage windows (switch, link, move, swap, rename, kill*).
        * Manage panes (switch, break, join*, swap, layout, kill*, resize).
        * Multiple selection (support for actions marked by *).
        * Search commands and append to command prompt.
        * Search key bindings and execute.
        * User menu.
        * Popup window support.
      '';

      homepage = "https://github.com/sainnhe/tmux-fzf";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ kyleondy ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-nova = mkTmuxPlugin rec {
    version = "1.2.0";

    src = fetchFromGitHub {
      owner = "o0th";
      repo = "tmux-nova";
      rev = "v${version}";
      hash = "sha256-0LIql8as2+OendEHVqR0F3pmQTxC1oqapwhxT+34lJo=";
    };

    pluginName = "tmux-nova";
    rtpFilePath = "nova.tmux";

    meta = {
      description = "Tmux-nova theme";
      homepage = "https://github.com/o0th/tmux-nova";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ o0th ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-powerline = mkTmuxPlugin {
    version = "3.0.0";

    src = fetchFromGitHub {
      owner = "erikw";
      repo = "tmux-powerline";
      rev = "2480e5531e0027e49a90eaf540f973e624443937";
      hash = "sha256-25uG7OI8OHkdZ3GrTxG1ETNeDtW1K+sHu2DfJtVHVbk=";
    };

    pluginName = "powerline";
    rtpFilePath = "main.tmux";

    meta = {
      description = "Empowering your tmux (status bar) experience";
      longDescription = "A tmux plugin giving you a hackable status bar consisting of dynamic & beautiful looking powerline segments, written purely in bash.";
      homepage = "https://github.com/erikw/tmux-powerline";
      license = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [ thomasjm ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-session-manager = mkTmuxPlugin rec {
    version = "1.1.2";

    src = fetchFromGitHub {
      owner = "PhilVoel";
      repo = "tmux-session-manager";
      tag = "v${version}";
      hash = "sha256-3uXl9N0LkS1txjaG8I+i1ACAW55tSNFzv358i3aRd/U=";
    };

    pluginName = "tmux-session-manager";
    rtpFilePath = "session_manager.tmux";

    meta = {
      description = "Save and restore your tmux sessions, one by one";
      homepage = "https://github.com/PhilVoel/tmux-session-manager";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ PhilVoel ];
    };
  };

  tmux-sessionx = mkTmuxPlugin {
    version = "0-unstable-2024-09-22";

    src = fetchFromGitHub {
      owner = "omerxx";
      repo = "tmux-sessionx";
      rev = "508359b8a6e2e242a9270292160624406be3bbca";
      hash = "sha256-nbzn3qxMGRzxFnLBVrjqGl09++9YOK4QrLoYiHUS9jY=";
    };

    postPatch = ''
      substituteInPlace sessionx.tmux \
        --replace-fail "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
      substituteInPlace scripts/sessionx.sh \
        --replace-fail "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
      substituteInPlace scripts/sessionx.sh \
        --replace-fail "/tmux-sessionx/scripts/reload_sessions.sh" "$out/share/tmux-plugins/sessionx/scripts/reload_sessions.sh"
    '';

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      chmod +x $target/scripts/sessionx.sh
      wrapProgram $target/scripts/sessionx.sh \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            zoxide
            fzf
            gnugrep
            gnused
            coreutils
          ]
        }
      chmod +x $target/scripts/preview.sh
      wrapProgram $target/scripts/preview.sh \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            coreutils
            gnugrep
            gnused
          ]
        }
      chmod +x $target/scripts/reload_sessions.sh
      wrapProgram $target/scripts/reload_sessions.sh \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            coreutils
            gnugrep
            gnused
          ]
        }
    '';

    pluginName = "sessionx";

    meta = {
      description = "Tmux session manager, with preview, fuzzy finding, and MORE";
      homepage = "https://github.com/omerxx/tmux-sessionx";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ okwilkins ];
      platforms = lib.platforms.all;
    };
  };

  tmux-sm = mkTmuxPlugin {
    version = "0-unstable-2026-05-14";

    src = fetchFromGitHub {
      owner = "vimlinuz";
      repo = "tmux-sm";
      rev = "97d411a11d124443c982d17fde03c1e09809d7b1";
      hash = "sha256-7HW/TLP/yyQp4j0/utA0tibTv+suV1B2K56pUS3Z004=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      chmod +x $target/scripts/session-manager
      wrapProgram $target/scripts/session-manager \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            fzf
            gawk
            coreutils
          ]
        }
      chmod +x $target/scripts/sessionizer
      wrapProgram $target/scripts/sessionizer \
        --prefix PATH : ${
          with pkgs;
          lib.makeBinPath [
            fzf
            tree
            findutils
            coreutils
          ]
        }
    '';

    pluginName = "tmux-sm";
    rtpFilePath = "main.tmux";

    meta = {
      description = "Fuzzy terminal popup to manage tmux sessions using `fzf`";
      homepage = "https://github.com/vimlinuz/tmux-sm";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ vimlinuz ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-thumbs = pkgs.callPackage ./tmux-thumbs {
    inherit mkTmuxPlugin;
  };

  tmux-toggle-popup = mkTmuxPlugin rec {
    version = "0.5.1";

    src = fetchFromGitHub {
      owner = "loichyan";
      repo = "tmux-toggle-popup";
      tag = "v${version}";
      hash = "sha256-daUCkt1Np8ZYvLc3Bx0HvhnI988q7lIayJju/GB6Klw=";
    };

    pluginName = "tmux-toggle-popup";
    rtpFilePath = "toggle-popup.tmux";

    meta = {
      description = "Handy plugin to create toggleable popups";
      homepage = "https://github.com/loichyan/tmux-toggle-popup";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ szaffarano ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-tpad = mkTmuxPlugin {
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "Subbeh";
      repo = "tmux-tpad";
      rev = "v0.3.0";
      hash = "sha256-w1eNg6n5JEWcKT7hCr3nFPe01kW3PwGBx8sdtfFojvk=";
    };

    pluginName = "tmux-tpad";
    rtpFilePath = "tpad.tmux";

    meta = {
      description = "Tmux scratchpad plugin";
      homepage = "https://github.com/Subbeh/tmux-tpad";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ anned20 ];
      platforms = lib.platforms.unix;
    };
  };

  tmux-which-key = pkgs.callPackage ./tmux-which-key {
    inherit mkTmuxPlugin;
  };

  tmux-window-name = mkTmuxPlugin {
    version = "2024-03-08";

    src = fetchFromGitHub {
      owner = "ofirgall";
      repo = "tmux-window-name";
      rev = "34026b6f442ceb07628bf25ae1b04a0cd475e9ae";
      sha256 = "sha256-BNgxLk/BkaQkGlB4g2WKVs39y4VHL1Y2TdTEoBy7yo0=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      script=$target/scripts/rename_session_windows.py

      sed -i \
        -e 's|^USR_BIN_REMOVER.*|USR_BIN_REMOVER = (r"^" + os.path.expanduser("~") + r"/.nix-profile/bin/(.+)( --.*)?", r"\\g<1>")|' \
        -e 's|^\(\s*\)substitute_sets: List.*|\1substitute_sets: List[Tuple] = field(default_factory=lambda: [(os.path.expanduser("~") + r"/.nix-profile/bin/(.+) --.*", r"\\g<1>"), (r".+ipython([32])", r"ipython\\g<1>"), USR_BIN_REMOVER, (r"(bash) (.+)/(.+[ $])(.+)", r"\\g<3>\\g<4>")])|' \
        -e 's|^\(\s*\)dir_programs: List.*|\1dir_programs: List[str] = field(default_factory=lambda: [os.path.expanduser("~") + "/.nix-profile/bin/" + p for p in ["vim", "vi", "git", "nvim"]])|' \
        $script

      for f in tmux_window_name.tmux scripts/rename_session_windows.py; do
        wrapProgram $target/$f \
          --prefix PATH : ${
            lib.makeBinPath [
              (pkgs.python3.withPackages (
                p: with p; [
                  libtmux
                  pip
                ]
              ))
            ]
          }
      done
    '';

    pluginName = "tmux-window-name";
    rtpFilePath = "tmux_window_name.tmux";

    meta = with lib; {
      description = "Tmux plugin to name your windows smartly, like IDE's";
      homepage = "https://github.com/ofirgall/tmux-window-name";
      license = licenses.mit;
      maintainers = with maintainers; [ ndom91 ];
      platforms = platforms.unix;
    };
  };

  tokyo-night-tmux = mkTmuxPlugin {
    version = "1.6.6";

    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "caf6cbb4c3a32d716dfedc02bc63ec8cf238f632";
      hash = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
    };

    pluginName = "tokyo-night-tmux";
    rtpFilePath = "tokyo-night.tmux";

    meta = {
      description = "Clean, dark Tmux theme that celebrates the lights of Downtown Tokyo at night";
      homepage = "https://github.com/janoamaral/tokyo-night-tmux";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ redyf ];
      platforms = lib.platforms.unix;
    };
  };

  ukiyo = mkTmuxPlugin {
    version = "0-unstable-2026-02-02";

    src = fetchFromGitHub {
      owner = "Nybkox";
      repo = "tmux-ukiyo";
      rev = "dd8730a2a41da79425c11c0cea69e0bd81545e19";
      hash = "sha256-jOcGNKb8QrIgT7l3D3RiJOPIC9JU1rOy8tk0x5ULrdc=";
    };

    pluginName = "ukiyo";

    meta = {
      description = "Feature packed ukiyo theme for tmux";
      homepage = "https://github.com/Nybkox/tmux-ukiyo";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ FKouhai ];
      platforms = lib.platforms.unix;
      downloadPage = "https://github.com/Nybkox/tmux-ukiyo";
    };
  };

  urlview = mkTmuxPlugin {
    version = "unstable-2016-01-06";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-urlview";
      rev = "b84c876cffdd22990b4ab51247e795cbd7813d53";
      hash = "sha256-1oEJDgHPIM6AEVlGcavRqP2YjPdmkxHHMiFYdgqW5Mo=";
    };

    postInstall = ''
      sed -i -e '14,20{s|extract_url|${pkgs.extract_url}/bin/extract_url|g}' $target/urlview.tmux
    '';

    pluginName = "urlview";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-urlview";
    };
  };

  vim-tmux-focus-events = mkTmuxPlugin {
    version = "unstable-2020-10-05";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "vim-tmux-focus-events";
      rev = "a568192ca0de4ca0bd7b3cd0249aad491625c941";
      hash = "sha256-ITZMu2q80deOf0zqgYJDDgWQHWhJEzZlK6lVFPY4FIw=";
    };

    pluginName = "vim-tmux-focus-events";

    meta = {
      description = "Makes FocusGained and FocusLost autocommand events work in vim when using tmux";
      homepage = "https://github.com/tmux-plugins/vim-tmux-focus-events";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ronanmacf ];
      platforms = lib.platforms.unix;
    };
  };

  vim-tmux-navigator = mkTmuxPlugin {
    version = "unstable-2025-07-15";

    src = fetchFromGitHub {
      owner = "christoomey";
      repo = "vim-tmux-navigator";
      rev = "c45243dc1f32ac6bcf6068e5300f3b2b237e576a";
      hash = "sha256-IEPnr/GdsAnHzdTjFnXCuMyoNLm3/Jz4cBAM0AJBrj8=";
    };

    pluginName = "vim-tmux-navigator";
    rtpFilePath = "vim-tmux-navigator.tmux";

    meta = {
      homepage = "https://github.com/christoomey/vim-tmux-navigator";
    };
  };

  weather = mkTmuxPlugin {
    version = "unstable-2020-02-08";

    src = fetchFromGitHub {
      owner = "xamut";
      repo = "tmux-weather";
      rev = "28a5fbe75bb25a408193d454304e28ddd75e9338";
      hash = "sha256-of9E/npEsF1JVc9ttwrbC5WkIAwCNBJAgTfExfj79i4=";
    };

    pluginName = "weather";
    rtpFilePath = "tmux-weather.tmux";

    meta = {
      description = "Shows weather in the status line";
      homepage = "https://github.com/xamut/tmux-weather";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ jfvillablanca ];
      platforms = lib.platforms.unix;
    };
  };

  yank = mkTmuxPlugin {
    version = "unstable-2023-07-19";

    src = fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-yank";
      rev = "acfd36e4fcba99f8310a7dfb432111c242fe7392";
      hash = "sha256-/5HPaoOx2U2d8lZZJo5dKmemu6hKgHJYq23hxkddXpA=";
    };

    pluginName = "yank";

    meta = {
      homepage = "https://github.com/tmux-plugins/tmux-yank";
    };
  };
}
// lib.optionalAttrs config.allowAliases {
  kanagawa = throw "'tmuxPlugins.kanagawa' has been renamed to/replaced by 'tmuxPlugins.ukiyo'"; # Converted to throw 2026-01-30
  mkDerivation = throw "tmuxPlugins.mkDerivation is deprecated, use tmuxPlugins.mkTmuxPlugin instead"; # added 2021-03-14
}
