{
  lib,
  stdenv,
  callPackage,
  config,
  gettext,
  glib,
  gtk2-x11,
  gtk3-x11,
  libice,
  libsm,
  libsodium,
  libx11,
  libxau,
  libxaw,
  libxext,
  libxmu,
  libxpm,
  libxt,
  # TODO: Clean up on `staging`
  llvmPackages,
  lua,
  makeWrapper,
  ncurses,
  perl,
  pkg-config,
  python3,
  ruby,
  tcl,
  vimPlugins,
  wayland-scanner,
  wrapGAppsHook3,
  writeText,
  cscopeSupport ? config.vim.cscope or true, # Enable cscope interface
  darwinSupport ? config.vim.darwin or false, # Enable Darwin support
  features ? "huge", # One of tiny, small, normal, big or huge
  ftNixSupport ? config.vim.ftNix or true, # Add nix indentation support from vim-nix (not needed for basic syntax highlighting)
  guiSupport ? config.vim.gui or (if stdenv.hostPlatform.isDarwin then "gtk2" else "gtk3"),
  luaSupport ? config.vim.lua or true,
  multibyteSupport ? config.vim.multibyte or false, # Enable multibyte editing support
  netbeansSupport ? config.netbeans or true, # Enable NetBeans integration support.
  nlsSupport ? config.vim.nls or false, # Enable NLS (gettext())
  perlSupport ? config.vim.perl or false, # Perl interpreter
  pythonSupport ? config.vim.python or true, # Python interpreter
  rubySupport ? config.vim.ruby or true, # Ruby interpreter
  sodiumSupport ? config.vim.sodium or true, # Enable sodium based encryption
  source ? "default",
  tclSupport ? config.vim.tcl or false, # Include Tcl interpreter
  waylandSupport ? !stdenv.hostPlatform.isDarwin,
  wrapPythonDrv ? false,
  ximSupport ? config.vim.xim or true, # less than 15KB, needed for deadkeys
}:

let
  nixosRuntimepath = writeText "nixos-vimrc" ''
    set nocompatible
    syntax on

    function! NixosPluginPath()
      let seen = {}
      for p in reverse(split($NIX_PROFILES))
        for d in split(glob(p . '/share/vim-plugins/*'))
          let pluginname = substitute(d, ".*/", "", "")
          if !has_key(seen, pluginname)
            exec 'set runtimepath^='.d
            let after = d."/after"
            if isdirectory(after)
              exec 'set runtimepath^='.after
            endif
            let seen[pluginname] = 1
          endif
        endfor
      endfor
    endfunction

    execute NixosPluginPath()

    if filereadable("/etc/vimrc")
      source /etc/vimrc
    elseif filereadable("/etc/vim/vimrc")
      source /etc/vim/vimrc
    endif
  '';

  common = callPackage ./common.nix { inherit stdenv; };

in
stdenv.mkDerivation {

  inherit (common)
    version
    outputs
    postPatch
    hardeningDisable
    enableParallelBuilding
    meta
    ;

  pname = "vim-full";

  src = builtins.getAttr source {
    default = common.src; # latest release
  };

  patches = [ ./cflags-prune.diff ];

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional wrapPythonDrv makeWrapper
  ++ lib.optional nlsSupport gettext
  ++ lib.optional perlSupport perl
  ++ lib.optional (guiSupport == "gtk3") wrapGAppsHook3
  ++ lib.optional waylandSupport wayland-scanner
  # TODO: Clean up on `staging`
  ++ lib.optional stdenv.hostPlatform.isDarwin llvmPackages.lld;

  buildInputs = [
    ncurses
    glib
  ]
  # All X related dependencies
  ++ lib.optionals (guiSupport == "gtk2" || guiSupport == "gtk3") [
    libsm
    libice
    libx11
    libxext
    libxpm
    libxt
    libxaw
    libxau
    libxmu
  ]
  ++ lib.optional (guiSupport == "gtk2") gtk2-x11
  ++ lib.optional (guiSupport == "gtk3") gtk3-x11
  ++ lib.optional luaSupport lua
  ++ lib.optional pythonSupport python3
  ++ lib.optional tclSupport tcl
  ++ lib.optional rubySupport ruby
  ++ lib.optional sodiumSupport libsodium;

  configureFlags = [
    "--with-features=${features}"
    "--disable-xsmp" # XSMP session management
    "--disable-xsmp_interact" # XSMP interaction
    "--disable-workshop" # Sun Visual Workshop support
    "--disable-sniff" # Sniff interface
    "--disable-hangulinput" # Hangul input support
    "--disable-fontset" # X fontset output support
    "--disable-acl" # ACL support
    "--disable-gpm" # GPM (Linux mouse daemon)
    "--disable-mzschemeinterp"
    "--disable-gtk_check"
    "--disable-gtk2_check"
    "--disable-gnome_check"
    "--disable-motif_check"
    "--disable-athena_check"
    "--disable-nextaf_check"
    "--disable-carbon_check"
    "--disable-gtktest"
    (lib.strings.enableFeature waylandSupport "wayland")
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "vim_cv_toupper_broken=no"
    "--with-tlib=ncurses"
    "vim_cv_terminfo=yes"
    "vim_cv_tgetent=zero" # it does on native anyway
    "vim_cv_tty_group=tty"
    "vim_cv_tty_mode=0660"
    "vim_cv_getcwd_broken=no"
    "vim_cv_stat_ignores_slash=yes"
    "vim_cv_memmove_handles_overlap=yes"
  ]
  ++ lib.optional (guiSupport == "gtk2" || guiSupport == "gtk3") "--enable-gui=${guiSupport}"
  ++ lib.optional stdenv.hostPlatform.isDarwin (
    if darwinSupport then "--enable-darwin" else "--disable-darwin"
  )
  ++ lib.optionals luaSupport [
    "--with-lua-prefix=${lua}"
    "--enable-luainterp"
  ]
  ++ lib.optionals lua.pkgs.isLuaJIT [
    "--with-luajit"
  ]
  ++ lib.optionals pythonSupport [
    "--enable-python3interp=yes"
    "--with-python3-config-dir=${python3}/lib"
    # Disables Python 2
    "--disable-pythoninterp"
  ]
  ++ lib.optional nlsSupport "--enable-nls"
  ++ lib.optional perlSupport "--enable-perlinterp"
  ++ lib.optional rubySupport "--enable-rubyinterp"
  ++ lib.optional tclSupport "--enable-tclinterp"
  ++ lib.optional multibyteSupport "--enable-multibyte"
  ++ lib.optional cscopeSupport "--enable-cscope"
  ++ lib.optional netbeansSupport "--enable-netbeans"
  ++ lib.optional ximSupport "--enable-xim"
  ++ lib.optional sodiumSupport "--enable-sodium";

  # error: '__declspec' attributes are not enabled; use '-fdeclspec' or '-fms-extensions' to enable support for __declspec attributes
  # workaround for ld64 hardening issue
  #
  # TODO: Clean up on `staging`
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-fdeclspec -fuse-ld=lld";

  preConfigure = lib.optionalString ftNixSupport ''
    cp ${vimPlugins.vim-nix.src}/ftplugin/nix.vim runtime/ftplugin/nix.vim
    cp ${vimPlugins.vim-nix.src}/indent/nix.vim runtime/indent/nix.vim
  '';

  preInstall = ''
    mkdir -p $out/share/applications $out/share/icons/{hicolor,locolor}/{16x16,32x32,48x48}/apps
  '';

  postInstall = ''
    ln -s $out/bin/vim $out/bin/vi
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -sfn '${nixosRuntimepath}' "$out"/share/vim/vimrc
  '';

  postFixup =
    common.postFixup
    + lib.optionalString wrapPythonDrv ''
      wrapProgram "$out/bin/vim" --prefix PATH : "${python3}/bin" \
        --set NIX_PYTHONPATH "${python3}/${python3.sitePackages}"
    '';

  dontStrip = true;
}
