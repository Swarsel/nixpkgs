{
  lib,
  stdenv,
  autoreconfHook,
  brotli,
  cjose,
  curl,
  fetchzip,
  file,
  geoip,
  hiredis,
  hwloc,
  imagemagick,
  jansson,
  kyotocabinet,
  libcap,
  libmaxminddb,
  libunwind,
  linuxHeaders,
  luajit,
  makeWrapper,
  ncurses,
  nixosTests,
  openssl,
  pcre,
  perlPackages,
  pkg-config,
  python3,
  # optional features
  enableWCCP ? false,
  # optional dependencies
  withBrotli ? false,
  withCap ? stdenv.hostPlatform.isLinux,
  withCjose ? false,
  withCurl ? true,
  withCurses ? true,
  withGeoIP ? false,
  withHiredis ? false,
  # recommended dependencies
  withHwloc ? true,
  withImageMagick ? false,
  withJansson ? false,
  withKyotoCabinet ? false,
  withLuaJIT ? false,
  withMaxmindDB ? false,
  withUnwind ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trafficserver";
  version = "9.2.11";

  src = fetchzip {
    url = "mirror://apache/trafficserver/trafficserver-${finalAttrs.version}.tar.bz2";
    hash = "sha256-WFABr7+JsUbQagLFK0OXZ20t4QCuYrozeaV4fKO/c2s=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    patchShebangs \
      iocore/aio/test_AIO.sample \
      src/traffic_via/test_traffic_via \
      src/traffic_logstats/tests \
      tools/check-unused-dependencies
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace configure.ac \
      --replace-fail '/usr/include/linux' '${linuxHeaders}/include/linux'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # 'xcrun leaks' probably requires non-free XCode
    substituteInPlace iocore/net/test_certlookup.cc \
      --replace-fail 'xcrun leaks' 'true'
  '';

  # NOTE: The upstream README indicates that flex is needed for some features,
  # but it actually seems to be unnecessary as of this commit[1]. The detection
  # logic for bison and flex is still present in the build script[2], but no
  # other code seems to depend on it. This situation is susceptible to change
  # though, so it's a good idea to inspect the build scripts periodically.
  #
  # [1]: https://github.com/apache/trafficserver/pull/5617
  # [2]: https://github.com/apache/trafficserver/blob/3fd2c60/configure.ac#L742-L788
  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
    file
    python3
  ]
  ++ (with perlPackages; [
    perl
    ExtUtilsMakeMaker
  ])
  ++ lib.optionals stdenv.hostPlatform.isLinux [ linuxHeaders ];

  buildInputs = [
    openssl
    pcre
    perlPackages.perl
  ]
  ++ lib.optional withBrotli brotli
  ++ lib.optional withCap libcap
  ++ lib.optional withCjose cjose
  ++ lib.optional withCurl curl
  ++ lib.optional withGeoIP geoip
  ++ lib.optional withHiredis hiredis
  ++ lib.optional withHwloc hwloc
  ++ lib.optional withImageMagick imagemagick
  ++ lib.optional withJansson jansson
  ++ lib.optional withKyotoCabinet kyotocabinet
  ++ lib.optional withCurses ncurses
  ++ lib.optional withLuaJIT luajit
  ++ lib.optional withUnwind libunwind
  ++ lib.optional withMaxmindDB libmaxminddb;

  configureFlags = [
    "--enable-layout=NixOS"
    "--enable-experimental-plugins"
    (lib.enableFeature enableWCCP "wccp")

    (lib.withFeatureAs withHiredis "hiredis" hiredis)
  ];

  doCheck = true;

  postInstall = ''
    install -Dm644 rc/trafficserver.service $out/lib/systemd/system/trafficserver.service

    wrapProgram $out/bin/tspush \
      --set PERL5LIB '${with perlPackages; makePerlPath [ URI ]}' \
      --prefix PATH : "${lib.makeBinPath [ file ]}"

    find "$out" -name '*.la' -delete

    # ensure no files actually exist in this directory
    rmdir $out/.install-trafficserver
  '';

  doInstallCheck = true;

  installCheckPhase =
    let
      expected = ''
        Via header is [uScMsEf p eC:t cCMp sF], Length is 22
        Via Header Details:
        Request headers received from client                   :simple request (not conditional)
        Result of Traffic Server cache lookup for URL          :miss (a cache "MISS")
        Response information received from origin server       :error in response
        Result of document write-to-cache:                     :no cache write performed
        Proxy operation result                                 :unknown
        Error codes (if any)                                   :connection to server failed
        Tunnel info                                            :no tunneling
        Cache Type                                             :cache
        Cache Lookup Result                                    :cache miss (url not in cache)
        Parent proxy connection status                         :no parent proxy or unknown
        Origin server connection status                        :connection open failed
      '';
    in
    ''
      runHook preInstallCheck
      diff -Naur <($out/bin/traffic_via '[uScMsEf p eC:t cCMp sF]') - <<EOF
      ${lib.removeSuffix "\n" expected}
      EOF
      runHook postInstallCheck
    '';

  enableParallelBuilding = true;

  installFlags = [
    "pkgsysconfdir=${placeholder "out"}/etc/trafficserver"

    # replace runtime directories with an install-time placeholder directory
    "pkgcachedir=${placeholder "out"}/.install-trafficserver"
    "pkglocalstatedir=${placeholder "out"}/.install-trafficserver"
    "pkglogdir=${placeholder "out"}/.install-trafficserver"
    "pkgruntimedir=${placeholder "out"}/.install-trafficserver"
  ];

  passthru.tests = { inherit (nixosTests) trafficserver; };

  meta = {
    description = "Fast, scalable, and extensible HTTP caching proxy server";

    longDescription = ''
      Apache Traffic Server is a high-performance web proxy cache that improves
      network efficiency and performance by caching frequently-accessed
      information at the edge of the network. This brings content physically
      closer to end users, while enabling faster delivery and reduced bandwidth
      use. Traffic Server is designed to improve content delivery for
      enterprises, Internet service providers (ISPs), backbone providers, and
      large intranets by maximizing existing and available bandwidth.
    '';

    homepage = "https://trafficserver.apache.org";
    changelog = "https://raw.githubusercontent.com/apache/trafficserver/${finalAttrs.version}/CHANGELOG-${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ midchildan ];
    platforms = lib.platforms.unix;
  };
})
