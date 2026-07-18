{
  lib,
  stdenv,
  bundlerEnv,
  callPackage,
  lndir,
  makeWrapper,
  neovim-node-client,
  neovimUtils,
  nodejs,
  perl,
  python3,
  ruby,
  runCommand,
  wayland,
  wl-clipboard,
  writeText,
}:

neovim-unwrapped:

let
  # inherit interpreter from neovim
  lua = neovim-unwrapped.lua;

  wrapper =
    {
      # certain plugins need a custom configuration (available in passthru.initLua)
      # to work with nix.
      # if true, the wrapper automatically appends those snippets when necessary
      autoconfigure ? true,
      # append to PATH runtime deps of plugins
      autowrapRuntimeDeps ? true,
      # the function you would have passed to lua.withPackages
      extraLuaPackages ? (_: [ ]),
      extraName ? "",
      # the function you would have passed to python3.withPackages
      extraPython3Packages ? (_: [ ]),
      # lua code to put into the generated init.lua file
      luaRcContent ? "",
      # vimL code that should be sourced as part of the generated init.lua file
      neovimRcContent ? null,
      # DEPRECATED: entry to load in packpath
      # use 'plugins' instead
      packpathDirs ? null, # not used anymore
      # a list of neovim plugin derivations, for instance
      #  plugins = [
      # { plugin=far-vim; config = "let g:far#source='rg'"; optional = false; }
      # ]
      plugins ? [ ],
      viAlias ? false,
      # wether to create symlinks in $out/bin/vi(m) -> $out/bin/nvim
      vimAlias ? false,
      waylandSupport ? lib.meta.availableOn stdenv.hostPlatform wayland,
      withNodeJs ? false,
      withPerl ? false,
      withPython2 ? false,
      withPython3 ? false,
      withRuby ? false,
      # it sets the VIMINIT environment variable to "lua dofile('${customRc}')"
      # set to false if you want to control where to save the generated config
      # (e.g., in ~/.config/init.vim or project/.nvimrc)
      wrapRc ? true,
      # should contain all args but the binary. Can be either a string or list
      wrapperArgs ? [ ],
      ...
    }@attrs:
    assert
      withPython2
      -> throw "Python2 support has been removed from the neovim wrapper, please remove withPython2 and python2Env.";

    assert
      packpathDirs != null
      -> throw "packpathdirs is not used anymore: pass a list of neovim plugin derivations in 'plugins' instead.";

    stdenv.mkDerivation (
      finalAttrs:
      let

        rubyEnv = bundlerEnv {
          postBuild = ''
            ln -sf ${ruby}/bin/* $out/bin
          '';

          gemdir = ./ruby_provider;
          name = "neovim-ruby-env";
        };

        # a limited RC script used only to generate the manifest for remote plugins
        manifestRc = "";

        # plugin-related information
        vimPackageInfo = neovimUtils.makeVimPackageInfo finalAttrs.plugins;

        # we call vimrcContent without 'packages' to avoid the init.vim generation
        neovimRcContent' = lib.concatStringsSep "\n" (
          lib.optional (vimPackageInfo.userPluginConfigs.viml or "" != "") (
            vimPackageInfo.userPluginConfigs.viml
          )
          ++ (lib.optional (neovimRcContent != null) neovimRcContent)
        );

        packpathDirs.myNeovimPackages = vimPackageInfo.vimPackage;
        finalPackdir = neovimUtils.packDir packpathDirs;

        luaDeps = extraLuaPackages lua.pkgs ++ vimPackageInfo.luaDependencies;

        luaPathLuaRc =
          let
            luaEnv = lua.withPackages (_: luaDeps);

            # getLuaPath / getLuaCPath are not interpreter dependant at the moment and might thus cause
            # errors between luajit/Puc lua
            generatedLuaPath = lua.pkgs.getLuaPath luaEnv;
            generatedLuaCPath = lua.pkgs.getLuaCPath luaEnv;
          in
          ''
            package.path = "${generatedLuaPath}".. ";" .. package.path
            package.cpath = "${generatedLuaCPath}".. ";" .. package.cpath
          '';

        rcContent = lib.concatStringsSep "\n" (
          lib.optional (luaDeps != [ ]) luaPathLuaRc
          ++ [ providerLuaRc ]
          ++ lib.optional (luaRcContent != "") luaRcContent
          ++ lib.optional (
            vimPackageInfo.userPluginConfigs.lua or "" != ""
          ) vimPackageInfo.userPluginConfigs.lua
          ++ lib.optional (neovimRcContent' != "") ''
            vim.cmd.source "${writeText "init.vim" neovimRcContent'}"
          ''
          ++ lib.optionals autoconfigure vimPackageInfo.pluginAdvisedLua
        );

        python3Env =
          lib.warnIf (attrs ? python3Env)
            "Pass your python packages via the `extraPython3Packages`, e.g., `extraPython3Packages = ps: [ ps.pandas ]`"
            python3.pkgs.python.withPackages
            (
              ps:
              [ ps.pynvim ]
              ++ (extraPython3Packages ps)
              ++ (lib.concatMap (f: f ps) vimPackageInfo.pluginPython3Packages)
            );

        wrapperArgsStr = if lib.isString wrapperArgs then wrapperArgs else lib.escapeShellArgs wrapperArgs;

        generatedWrapperArgs =

          # neovimUtils.legacyWrapper adds a `legacyWrapper` attribute to let us know we run in "legacy" mode
          lib.optionals (attrs ? legacyWrapper) [
            # vim accepts a limited number of commands so we join all the provider ones
            "--add-flags"
            ''--cmd "lua ${providerLuaRc}"''
          ]
          ++
            lib.optionals
              (
                finalAttrs.packpathDirs.myNeovimPackages.start != [ ]
                || finalAttrs.packpathDirs.myNeovimPackages.opt != [ ]
              )
              [
                "--add-flags"
                ''--cmd "set packpath^=${finalPackdir}"''
                "--add-flags"
                ''--cmd "set rtp^=${finalPackdir}"''
              ]
          ++ lib.optionals finalAttrs.withRuby [
            "--set"
            "GEM_HOME"
            "${rubyEnv}/${rubyEnv.ruby.gemPath}"
          ]
          ++ lib.optionals (finalAttrs.runtimeDeps != [ ]) [
            "--suffix"
            "PATH"
            ":"
            (lib.makeBinPath finalAttrs.runtimeDeps)
          ];

        providerLuaRc =
          let
            hostPython3 =
              runCommand "nvim-host-${python3Env.name}"
                {
                  nativeBuildInputs = [
                    makeWrapper
                  ];
                }
                ''
                  makeWrapper ${python3Env.interpreter} $out/bin/nvim-python3 --unset PYTHONPATH --unset PYTHONSAFEPATH
                '';

            genProviderCommand =
              prog: withProg: exec:
              if withProg then
                "vim.g.${prog}_host_prog='${exec}'"
              else
                # speeds up neovim by bypassing provider discovery
                "vim.g.loaded_${prog}_provider=0";
          in
          lib.concatStringsSep ";" [
            (genProviderCommand "node" finalAttrs.withNodeJs "${neovim-node-client}/bin/neovim-node-host")
            (genProviderCommand "perl" finalAttrs.withPerl "${perlEnv}/bin/perl")
            (genProviderCommand "ruby" finalAttrs.withRuby "${finalAttrs.rubyEnv}/bin/neovim-ruby-host")
            (genProviderCommand "python3" finalAttrs.withPython3 "${hostPython3}/bin/nvim-python3")
          ];

        # If `configure` != {}, we can't generate the rplugin.vim file with e.g
        # NVIM_SYSTEM_RPLUGIN_MANIFEST *and* NVIM_RPLUGIN_MANIFEST env vars set in
        # the wrapper. That's why only when `configure` != {} (tested both here and
        # when `postBuild` is evaluated), we call makeWrapper once to generate a
        # wrapper with most arguments we need, excluding those that cause problems to
        # generate rplugin.vim, but still required for the final wrapper.
        finalMakeWrapperArgs = [
          "${neovim-unwrapped}/bin/nvim"
          "${placeholder "out"}/bin/nvim"
        ]
        ++ [
          "--set"
          "NVIM_SYSTEM_RPLUGIN_MANIFEST"
          "${placeholder "out"}/rplugin.vim"
        ]
        ++ lib.optionals finalAttrs.wrapRc [
          "--set-default"
          "VIMINIT"
          "lua dofile('${writeText "init.lua" finalAttrs.luaRcContent}')"
        ]
        ++ finalAttrs.generatedWrapperArgs;

        perlEnv = perl.withPackages (p: [
          p.NeovimExt
          p.Appcpanminus
        ]);

        pname = "neovim";
        version = lib.getVersion neovim-unwrapped;
      in
      {
        inherit pname version;
        inherit plugins;

        inherit
          viAlias
          vimAlias
          waylandSupport
          withNodeJs
          withPython3
          withPerl
          withRuby
          ;

        inherit
          autoconfigure
          autowrapRuntimeDeps
          wrapRc
          providerLuaRc
          packpathDirs
          ;

        inherit python3Env rubyEnv;
        inherit wrapperArgs generatedWrapperArgs;
        strictDeps = true;

        nativeBuildInputs = [
          makeWrapper
          lndir
        ];

        buildPhase = ''
          runHook preBuild
          mkdir -p $out
          for i in ${neovim-unwrapped}; do
            lndir -silent $i $out
          done
          runHook postBuild
        '';

        # Remove the symlinks created by symlinkJoin which we need to perform
        # extra actions upon
        postBuild =
          lib.optionalString stdenv.hostPlatform.isLinux ''
            rm $out/share/applications/nvim.desktop
            substitute ${neovim-unwrapped}/share/applications/nvim.desktop $out/share/applications/nvim.desktop \
              --replace-warn 'Name=Neovim' 'Name=Neovim wrapper'
          ''
          + lib.optionalString finalAttrs.vimAlias ''
            ln -s $out/bin/nvim $out/bin/vim
          ''
          + lib.optionalString finalAttrs.viAlias ''
            ln -s $out/bin/nvim $out/bin/vi
          ''
          + lib.optionalString (manifestRc != null) (
            let
              manifestWrapperArgs = [
                "${neovim-unwrapped}/bin/nvim"
                "${placeholder "out"}/bin/nvim-wrapper"
              ]
              ++ finalAttrs.generatedWrapperArgs;
            in
            ''
              echo "Generating remote plugin manifest"
              export NVIM_RPLUGIN_MANIFEST=$out/rplugin.vim
              makeWrapper ${lib.escapeShellArgs manifestWrapperArgs} ${wrapperArgsStr}

              # Some plugins assume that the home directory is accessible for
              # initializing caches, temporary files, etc. Even if the plugin isn't
              # actively used, it may throw an error as soon as Neovim is launched
              # (e.g., inside an autoload script), causing manifest generation to
              # fail. Therefore, let's create a fake home directory before generating
              # the manifest, just to satisfy the needs of these plugins.
              #
              # See https://github.com/Yggdroot/LeaderF/blob/v1.21/autoload/lfMru.vim#L10
              # for an example of this behavior.
              export HOME="$(mktemp -d)"
              # Launch neovim with a vimrc file containing only the generated plugin
              # code. Pass various flags to disable temp file generation
              # (swap/viminfo) and redirect errors to stderr.
              # Only display the log on error since it will contain a few normally
              # irrelevant messages.
              if ! $out/bin/nvim-wrapper \
                -u ${writeText "manifest.vim" manifestRc} \
                -i NONE -n \
                -V1rplugins.log \
                +UpdateRemotePlugins +quit! > outfile 2>&1; then
                cat outfile
                echo -e "\nGenerating rplugin.vim failed!"
                exit 1
              fi
              rm "${placeholder "out"}/bin/nvim-wrapper"
            ''
          )
          + ''
            rm $out/bin/nvim
            touch $out/rplugin.vim

            makeWrapper ${lib.escapeShellArgs finalMakeWrapperArgs} ${wrapperArgsStr}
          '';

        checkPhase = ''
          runHook preCheck

          $out/bin/nvim -i NONE -e +quitall!
          runHook postCheck
        '';

        __structuredAttrs = true;
        dontUnpack = true;
        luaRcContent = rcContent;
        name = "${pname}-${version}${extraName}";
        preferLocalBuild = true;

        runtimeDeps =
          lib.optionals finalAttrs.waylandSupport [ wl-clipboard ]
          ++ lib.optional finalAttrs.withRuby rubyEnv
          ++ lib.optional finalAttrs.withNodeJs nodejs
          ++ lib.optionals finalAttrs.autowrapRuntimeDeps vimPackageInfo.runtimeDeps;

        vimPackage = vimPackageInfo.vimPackage;

        passthru = {
          inherit providerLuaRc packpathDirs;
          initRc = neovimRcContent';
          tests = callPackage ./tests { };
          unwrapped = neovim-unwrapped;
        };

        meta = {
          inherit (neovim-unwrapped.meta)
            description
            longDescription
            homepage
            mainProgram
            license
            teams
            platforms
            ;

          # To prevent builds on hydra
          hydraPlatforms = [ ];
          # prefer wrapper over the package
          priority = (neovim-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
        };
      }
    );
in
lib.makeOverridable wrapper
