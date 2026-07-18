{
  lib,
  buildEnv,
  perlPackages,
  python3Packages,
  runCommand,
  runtimeShell,
  writeScriptBin,
}:

weechat:

let
  wrapper =
    {
      configure ?
        { availablePlugins, ... }:
        {
          # Do not include PHP by default, because it bloats the closure, doesn't
          # build on Darwin, and there are no official PHP scripts.
          plugins = builtins.attrValues (removeAttrs availablePlugins [ "php" ]);
        },
      installManPages ? true,
    }:

    let
      perlInterpreter = perlPackages.perl;
      availablePlugins =
        let
          simplePlugin = name: { pluginFile = "${weechat.${name}}/lib/weechat/plugins/${name}.so"; };
        in
        rec {
          guile = simplePlugin "guile";
          lua = simplePlugin "lua";

          perl = (simplePlugin "perl") // {
            extraEnv = ''
              export PATH="${perlInterpreter}/bin:$PATH"
            '';

            withPackages =
              pkgsFun:
              (
                perl
                // {
                  extraEnv = ''
                    ${perl.extraEnv}
                    export PERL5LIB=${perlPackages.makeFullPerlPath (pkgsFun perlPackages)}
                  '';
                }
              );
          };

          php = simplePlugin "php";

          python = (simplePlugin "python") // {
            extraEnv = ''
              export PATH="${python3Packages.python}/bin:$PATH"
            '';

            withPackages =
              pkgsFun:
              (
                python
                // {
                  extraEnv = ''
                    ${python.extraEnv}
                    export PYTHONHOME="${python3Packages.python.withPackages pkgsFun}"
                  '';
                }
              );
          };

          ruby = simplePlugin "ruby";
          tcl = simplePlugin "tcl";
        };

      config = configure { inherit availablePlugins; };

      plugins = config.plugins or (builtins.attrValues availablePlugins);

      pluginsDir = runCommand "weechat-plugins" { } ''
        mkdir -p $out/plugins
        for plugin in ${lib.concatMapStringsSep " " (p: p.pluginFile) plugins} ; do
          ln -s $plugin $out/plugins
        done
      '';

      init =
        let
          init = builtins.replaceStrings [ "\n" ] [ ";" ] (config.init or "");

          mkScript = drv: lib.forEach drv.scripts (script: "/script load ${drv}/share/${script}");

          scripts = builtins.concatStringsSep ";" (
            lib.foldl (scripts: drv: scripts ++ mkScript drv) [ ] (config.scripts or [ ])
          );
        in
        "${scripts};${init}";

      mkWeechat =
        bin:
        (writeScriptBin bin ''
          #!${runtimeShell}
          export WEECHAT_EXTRA_LIBDIR=${pluginsDir}
          ${lib.concatMapStringsSep "\n" (p: lib.optionalString (p ? extraEnv) p.extraEnv) plugins}
          exec ${weechat}/bin/${bin} "$@" --run-command ${lib.escapeShellArg init}
        '')
        // {
          inherit (weechat) name man;

          outputs = [
            "out"
            "man"
          ];

          unwrapped = weechat;
        };
    in
    buildEnv {
      inherit (weechat) version;
      pname = "weechat-bin-env";
      extraOutputsToInstall = lib.optionals installManPages [ "man" ];

      paths = [
        (mkWeechat "weechat")
        (mkWeechat "weechat-headless")
        (runCommand "weechat-out-except-bin" { } ''
          mkdir $out
          ln -sf ${weechat}/include $out/include
          ln -sf ${weechat}/lib $out/lib
          ln -sf ${weechat}/share $out/share
        '')
      ];

      meta = removeAttrs weechat.meta [ "outputsToInstall" ];
    };

in
lib.makeOverridable wrapper
