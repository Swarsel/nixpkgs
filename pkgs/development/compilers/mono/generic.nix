{
  lib,
  stdenv,
  autoconf,
  automake,
  bash,
  bison,
  cacert,
  cmake,
  gettext,
  glib,
  gnumake42,
  libgdiplus,
  libtool,
  libx11,
  ncurses,
  perl,
  pkg-config,
  python3,
  src,
  version,
  which,
  zlib,
  enableParallelBuilding ? true,
  env ? { },
  extraPatches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version src env;
  inherit enableParallelBuilding;
  pname = "mono";
  # We want pkg-config to take priority over the dlls in the Mono framework and the GAC
  # because we control pkg-config
  patches = [ ./pkgconfig-before-gac.patch ] ++ extraPatches;
  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    bison
    cmake
    libtool
    perl
    pkg-config
    python3
    which
    gnumake42
    gettext
  ];

  buildInputs = [
    glib
    gettext
    libgdiplus
    libx11
    ncurses
    zlib
    bash
  ];

  configureFlags = [
    "--x-includes=${libx11.dev}/include"
    "--x-libraries=${libx11.out}/lib"
    "--with-libgdiplus=${libgdiplus}/lib/libgdiplus.so"
  ];

  # Patch all the necessary scripts
  preBuild = ''
    makeFlagsArray=(INSTALL=`type -tp install`)
    substituteInPlace mcs/class/corlib/System/Environment.cs --replace-fail /usr/share "$out/share"
  '';

  # Fix mono DLLMap so it can find libx11 to run winforms apps
  # libgdiplus is correctly handled by the --with-libgdiplus configure flag
  # Other items in the DLLMap may need to be pointed to their store locations, I don't think this is exhaustive
  # https://www.mono-project.com/Config_DllMap
  postBuild = ''
    find . -name 'config' -type f | xargs \
    sed -i -e "s@libX11.so.6@${libx11.out}/lib/libX11.so.6@g"
  '';

  # Without this, any Mono application attempting to open an SSL connection will throw with
  # The authentication or decryption has failed.
  # ---> Mono.Security.Protocol.Tls.TlsException: Invalid certificate received from server.
  postInstall = ''
    echo "Updating Mono key store"
    $out/bin/cert-sync ${cacert}/etc/ssl/certs/ca-bundle.crt
  ''
  # According to [1], gmcs is just mcs
  # [1] https://github.com/mono/mono/blob/master/scripts/gmcs.in
  + ''
    ln -s $out/bin/mcs $out/bin/gmcs
  '';

  configurePhase = ''
    patchShebangs autogen.sh mcs/build/start-compiler-server.sh
    ./autogen.sh --prefix $out $configureFlags
  '';

  meta = {
    description = "Cross platform, open source .NET development framework";

    homepage =
      if lib.versionOlder finalAttrs.version "6.14.0" then
        "https://mono-project.com/"
      else
        "https://gitlab.winehq.org/mono/mono";

    license = with lib.licenses; [
      # runtime, compilers, tools and most class libraries licensed
      mit
      # runtime includes some code licensed
      bsd3
      # mcs/class/I18N/mklist.sh marked GPLv2 and others just GPL
      gpl2Only
      # RabbitMQ.Client class libraries dual licensed
      mpl20
      asl20
      # mcs/class/System.Core/System/TimeZoneInfo.Android.cs
      asl20
      # some documentation
      mspl
      # https://www.mono-project.com/docs/faq/licensing/
      # https://github.com/mono/mono/blob/main/LICENSE
    ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      obadz
    ];

    platforms = with lib.platforms; darwin ++ linux;
    mainProgram = "mono";

    # Per nixpkgs#151720 the build failures for aarch64-darwin are fixed since 6.12.0.129.
    # Cross build is broken due to attempt to execute cert-sync built for the host.
    broken =
      (
        stdenv.hostPlatform.isDarwin
        && stdenv.hostPlatform.isAarch64
        && lib.versionOlder finalAttrs.version "6.12.0.129"
      )
      || !stdenv.buildPlatform.canExecute stdenv.hostPlatform;

    knownVulnerabilities = lib.optionals (lib.versionOlder finalAttrs.version "6.14.0") [
      ''
        mono was archived upstream, see https://www.mono-project.com/
        While WineHQ has taken over development, consider using 6.14.0 or newer.
      ''
    ];
  };
})
