{
  lib,
  stdenv,
  fetchurl,
  asciidoctor, # manpages
  cjson,
  cmake,
  cpputest,
  curl,
  enchant,
  gettext,
  gnutls,
  guile,
  libargon2,
  libgcrypt,
  libiconv,
  libresolv,
  libxml2,
  lua5_3,
  ncurses,
  openssl,
  pcre2,
  perl,
  php,
  pkg-config,
  python3Packages,
  ruby,
  systemdLibs,
  tcl,
  versionCheckHook,
  writeScript,
  zlib,
  enableTests ? !stdenv.hostPlatform.isDarwin,
  extraBuildInputs ? [ ],
  guileSupport ? true,
  luaSupport ? true,
  perlSupport ? true,
  phpSupport ? !stdenv.hostPlatform.isDarwin,
  pythonSupport ? true,
  rubySupport ? true,
  tclSupport ? true,
}:

let
  inherit (python3Packages) python;
  php-embed = php.override {
    apxs2Support = false;
    embedSupport = true;
  };
  plugins = [
    {
      buildInputs = [ perl ];
      cmakeFlag = "ENABLE_PERL";
      enabled = perlSupport;
      name = "perl";
    }
    {
      buildInputs = [ tcl ];
      cmakeFlag = "ENABLE_TCL";
      enabled = tclSupport;
      name = "tcl";
    }
    {
      buildInputs = [ ruby ];
      cmakeFlag = "ENABLE_RUBY";
      enabled = rubySupport;
      name = "ruby";
    }
    {
      buildInputs = [ guile ];
      cmakeFlag = "ENABLE_GUILE";
      enabled = guileSupport;
      name = "guile";
    }
    {
      buildInputs = [ lua5_3 ];
      cmakeFlag = "ENABLE_LUA";
      enabled = luaSupport;
      name = "lua";
    }
    {
      buildInputs = [ python ];
      cmakeFlag = "ENABLE_PYTHON3";
      enabled = pythonSupport;
      name = "python";
    }
    {
      buildInputs = [
        php-embed.unwrapped.dev
        libxml2
        pcre2
        libargon2
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [ systemdLibs ];

      cmakeFlag = "ENABLE_PHP";
      enabled = phpSupport;
      name = "php";
    }
  ];
  enabledPlugins = builtins.filter (p: p.enabled) plugins;

in

assert lib.all (p: p.enabled -> !(builtins.elem null p.buildInputs)) plugins;

stdenv.mkDerivation rec {
  pname = "weechat";
  version = "4.9.3";

  src = fetchurl {
    url = "https://weechat.org/files/src/weechat-${version}.tar.xz";
    hash = "sha256-XH2VOfqGyZ6nalUaiJqSusIeq3uyeQ29NGRS0AsQw3w=";
  };

  outputs = [
    "out"
    "man"
  ]
  ++ map (p: p.name) enabledPlugins;

  # Why is this needed? https://github.com/weechat/weechat/issues/2031
  patches = lib.optionals gettext.gettextNeedsLdflags [
    ./gettext-intl.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    asciidoctor
  ]
  ++ lib.optionals enableTests [ cpputest ];

  buildInputs = [
    ncurses
    openssl
    cjson
    enchant
    gnutls
    gettext
    zlib
    curl
    libgcrypt
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libresolv
  ]
  ++ lib.concatMap (p: p.buildInputs) enabledPlugins
  ++ extraBuildInputs;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_MAN" true)
    (lib.cmakeBool "ENABLE_DOC" true)
    (lib.cmakeBool "ENABLE_DOC_INCOMPLETE" true)
    (lib.cmakeBool "ENABLE_TESTS" enableTests)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeFeature "ICONV_LIBRARY" "${libiconv}/lib/libiconv.dylib")
  ]
  ++ map (p: lib.cmakeBool p.cmakeFlag p.enabled) plugins;

  env.NIX_CFLAGS_COMPILE =
    "-I${python}/include/${python.libPrefix}"
    # Fix '_res_9_init: undefined symbol' error
    + (lib.optionalString stdenv.hostPlatform.isDarwin "-DBIND_8_COMPAT=1 -lresolv");

  postInstall = ''
    for p in ${lib.concatMapStringsSep " " (p: p.name) enabledPlugins}; do
      from=$out/lib/weechat/plugins/$p.so
      to=''${!p}/lib/weechat/plugins/$p.so
      mkdir -p $(dirname $to)
      mv $from $to
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = writeScript "update-weechat" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p coreutils gawk git gnugrep common-updater-scripts
    set -eu -o pipefail

    version="$(git ls-remote --refs https://github.com/weechat/weechat | \
      awk '{ print $2 }' | \
      grep "refs/tags/v" | \
      sed -E -e 's,refs/tags/v(.*)$,\1,' | \
      sort --version-sort --reverse | \
      head -n1)"
    update-source-version weechat-unwrapped "$version"
  '';

  meta = {
    description = "Fast, light and extensible chat client";

    longDescription = ''
      You can find more documentation as to how to customize this package
      (e.g. adding python modules for scripts that would require them, etc.)
      on https://nixos.org/nixpkgs/manual/#sec-weechat .
    '';

    homepage = "https://weechat.org/";
    changelog = "https://github.com/weechat/weechat/releases/tag/v${version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ abbe ];
    platforms = lib.platforms.unix;
    mainProgram = "weechat";
  };
}
