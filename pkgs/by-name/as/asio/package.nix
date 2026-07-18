{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  openssl,
  pkg-config,
  testers,
  asioVersion ? "1.38.0",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asio";
  version = asioVersion;

  src = fetchFromGitHub {
    owner = "chriskohlhoff";
    repo = "asio";
    tag = "asio-${lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version}";

    hash =
      {
        # Preserve 1.32.0 because some project depends on asio/io_service.hpp
        "1.32.0" = "sha256-PBoa4OAOOmHas9wCutjz80rWXc3zGONntb9vTQk3FNY=";
        "1.36.0" = "sha256-BhJpE5+t0WXsuQ5CtncU0P8Kf483uFoV+OGlFLc7TpQ=";
        "1.38.0" = "sha256-pkSu8XMibmRPMoS3v5hO34oJb077bYc9KWELj3t8D6M=";
      }
      .${asioVersion} or (throw "Unsupported asio version. Please use overrideAttrs directly");
  };

  patches = [
    # Linking against `boost_system` fails because the stub compiled library
    # of Boost.System, which has been a header-only library since 1.69, was
    # removed in 1.89.
    # Upstream issue: https://github.com/chriskohlhoff/asio/issues/1716
    ./boost-1.89.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = lib.optionals finalAttrs.finalPackage.doCheck [
    # Only used in tests, "HAVE_BOOST_COROUTINE"
    "--enable-boost-coroutine"

    # There is also the "--with-boost" flag, but
    # after several tests, it doesn't make any difference
    # in the output.
  ];

  doCheck = true;

  # Only used for test coverage
  checkInputs = [
    openssl
    boost
  ];

  enableParallelBuilding = true;

  sourceRoot =
    finalAttrs.src.name + lib.optionalString (lib.versionOlder finalAttrs.version "1.38.0") "/asio";

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = true;
  };

  meta = {
    description = "Cross-platform C++ library for network and low-level I/O programming";
    homepage = "https://think-async.com/Asio";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "asio" ];
  };
})
