{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "s2n-tls";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "s2n-tls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oqWTcUGutEn5cOggiY1yPUlVWiHYKjnwBCCrEeWYn0A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ]; # s2n-config has find_dependency(LibCrypto).
  propagatedBuildInputs = [ openssl ]; # s2n-config has find_dependency(LibCrypto).

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DUNSAFE_TREAT_WARNINGS_AS_ERRORS=OFF" # disable -Werror
  ]
  ++ lib.optionals stdenv.hostPlatform.isMips64 [
    # See https://github.com/aws/s2n-tls/issues/1592 and https://github.com/aws/s2n-tls/pull/1609
    "-DS2N_NO_PQ=ON"
  ];

  postInstall = ''
    # Glob for 'shared' or 'static' subdir
    for f in $out/lib/s2n/cmake/*/s2n-targets.cmake; do
      substituteInPlace "$f" \
        --replace-fail 'INTERFACE_INCLUDE_DIRECTORIES "''${_IMPORT_PREFIX}/include"' 'INTERFACE_INCLUDE_DIRECTORIES ""'
    done
  '';

  passthru.tests = {
    inherit nix;
  };

  meta = {
    description = "C99 implementation of the TLS/SSL protocols";
    homepage = "https://github.com/aws/s2n-tls";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
