{
  lib,
  stdenv,
  fetchFromGitHub,
  expat,
  jansson,
  libcap,
  libxcrypt,
  makeWrapper,
  ncurses,
  nixosTests,
  openssl,
  pam,
  pcre2,
  php,
  pkg-config,
  python3,
  ruby,
  systemd,
  zlib,
  # plugins: list of strings, eg. [ "python3" ]
  plugins ? [ ],
  withCap ? stdenv.hostPlatform.isLinux,
  withPAM ? stdenv.hostPlatform.isLinux,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

let
  php-embed = php.override {
    apxs2Support = false;
    embedSupport = true;
  };

  available = lib.listToAttrs [
    (lib.nameValuePair "python3" {
      inputs = [
        python3
        ncurses
      ];

      install = ''
        install -Dm644 uwsgidecorators.py $out/${python3.sitePackages}/uwsgidecorators.py
        ${python3.pythonOnBuildForHost.executable} -m compileall $out/${python3.sitePackages}/
        ${python3.pythonOnBuildForHost.executable} -O -m compileall $out/${python3.sitePackages}/
      '';

      interpreter = python3.pythonOnBuildForHost.interpreter;
      path = "plugins/python";
    })
    (lib.nameValuePair "rack" {
      inputs = [ ruby ];
      path = "plugins/rack";
    })
    (lib.nameValuePair "cgi" {
      inputs = [ ];
      # usage: https://uwsgi-docs.readthedocs.io/en/latest/CGI.html?highlight=cgi
      path = "plugins/cgi";
    })
    (lib.nameValuePair "php" {
      inputs = [
        php-embed
        php-embed.extensions.session
        php-embed.extensions.session.dev
        php-embed.unwrapped.dev
      ]
      ++ php-embed.unwrapped.buildInputs;

      # usage: https://uwsgi-docs.readthedocs.io/en/latest/PHP.html#running-php-apps-with-nginx
      path = "plugins/php";
    })
    (lib.nameValuePair "http" {
      inputs = [ openssl.dev ];
      # usage: https://uwsgi-docs.readthedocs.io/en/latest/HTTP.html
      # usage: https://uwsgi-docs.readthedocs.io/en/latest/HTTPS.html
      path = "plugins/http";
    })
  ];

  getPlugin =
    name:
    let
      all = lib.concatStringsSep ", " (lib.attrNames available);
    in
    if lib.hasAttr name available then
      lib.getAttr name available // { inherit name; }
    else
      throw "Unknown UWSGI plugin ${name}, available : ${all}";

  needed = map getPlugin plugins;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "uwsgi";
  version = "2.0.31";

  src = fetchFromGitHub {
    owner = "unbit";
    repo = "uwsgi";
    tag = finalAttrs.version;
    hash = "sha256-WWZ+ClLWoUFi64xsiyuLXcxQsYdOv1DVhG+4oVYJJMI=";
  };

  patches = [
    ./no-ext-session-php_session.h-on-NixOS.patch
    ./additional-php-ldflags.patch
  ];

  postPatch = ''
    for f in uwsgiconfig.py plugins/*/uwsgiplugin.py; do
      substituteInPlace "$f" \
        --replace pkg-config "$PKG_CONFIG"
    done
    sed -e "s/ + php_version//" -i plugins/php/uwsgiplugin.py
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3
  ];

  buildInputs = [
    jansson
    pcre2
    libxcrypt
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    expat
    zlib
  ]
  ++ lib.optional withPAM pam
  ++ lib.optional withSystemd systemd
  ++ lib.optional withCap libcap
  ++ lib.concatMap (x: x.inputs) needed;

  env = {
    # UWSGI_INCLUDES environment variable required for "auto" plugins
    # to be detected. See uwsgiconfig.py for more details.
    UWSGI_INCLUDES = lib.concatStringsSep "," (
      map (p: "${lib.getDev p}/include") finalAttrs.buildInputs
    );
  }
  // lib.optionalAttrs (lib.any (x: x.name == "php") needed) {
    # this is a hack to make the php plugin link with session.so (which on nixos is a separate package)
    # the hack works in coordination with ./additional-php-ldflags.patch
    UWSGICONFIG_PHP_LDFLAGS = lib.concatStringsSep "," [
      "-Wl"
      "-rpath=${php-embed.extensions.session}/lib/php/extensions/"
      "--library-path=${php-embed.extensions.session}/lib/php/extensions/"
      "-l:session.so"
    ];
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $pluginDir
    python3 uwsgiconfig.py --build nixos
    ${lib.concatMapStringsSep ";" (
      x:
      "${x.preBuild or ""}\n ${x.interpreter or "python3"} uwsgiconfig.py --plugin ${x.path} nixos ${x.name}"
    ) needed}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 uwsgi $out/bin/uwsgi
    ${lib.concatMapStringsSep "\n" (x: x.install or "") needed}

    runHook postInstall
  '';

  postFixup = lib.optionalString (lib.any (x: x.name == "php") needed) ''
    wrapProgram $out/bin/uwsgi --set PHP_INI_SCAN_DIR ${php-embed}/lib
  '';

  basePlugins = lib.concatStringsSep "," (
    lib.optional withPAM "pam" ++ lib.optional withSystemd "systemd_logger"
  );

  configurePhase = ''
    runHook preConfigure

    export pluginDir=$out/lib/uwsgi
    substituteAll ${./nixos.ini} buildconf/nixos.ini

    runHook postConfigure
  '';

  passthru = {
    inherit python3;
    tests.uwsgi = nixosTests.uwsgi;
  };

  meta = {
    description = "Fast, self-healing and developer/sysadmin-friendly application container server coded in pure C";
    homepage = "https://uwsgi-docs.readthedocs.org/en/latest/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      globin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "uwsgi";
  };
})
