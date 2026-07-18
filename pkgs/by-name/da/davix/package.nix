{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fetchpatch,
  gsoap,
  libuuid,
  libxml2,
  openssl,
  pkg-config,
  python3,
  rapidjson,
  zlib,
  # Use libcurl instead of libneon
  # Note that the libneon used is bundled in the project
  # See https://github.com/cern-fts/davix/issues/23
  defaultToLibcurl ? false,
  enableIpv6 ? true,
  enableTcpNodelay ? true,
  # Build davix_copy.so
  enableThirdPartyCopy ? false,
  enableTools ? true,
}:

let
  boolToUpper = b: lib.toUpper (lib.boolToString b);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "davix" + lib.optionalString enableThirdPartyCopy "-copy";
  version = "0.8.10";

  src = fetchFromGitHub {
    owner = "cern-fts";
    repo = "davix";
    tag = "R_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-n4NeHBgQwGwgHAFQzPc3oEP9k3F/sqrTmkI/zHW+Miw=";
  };

  patches = [
    # Update CMake minimum requirement and supported versions, backport from unreleased davix 0.8.11
    (fetchpatch {
      hash = "sha256-FNXOQrY0gsMK+D4jwbJmYyEqD3lFui0giXUd+Rr0jLk=";
      url = "https://github.com/cern-fts/davix/commit/687d424c9f87888c94d96f3ea010de11ef70cd23.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    curl
    libxml2
    openssl
    rapidjson
    zlib
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) libuuid
  ++ lib.optional enableThirdPartyCopy gsoap;

  cmakeFlags = [
    "-DDAVIX_TESTS=OFF"
    "-DENABLE_TOOLS=${boolToUpper enableTools}"
    "-DEMBEDDED_LIBCURL=OFF"
    "-DLIBCURL_BACKEND_BY_DEFAULT=${boolToUpper defaultToLibcurl}"
    "-DENABLE_IPV6=${boolToUpper enableIpv6}"
    "-DENABLE_TCP_NODELAY=${boolToUpper enableTcpNodelay}"
    "-DENABLE_THIRD_PARTY_COPY=${boolToUpper enableThirdPartyCopy}"
  ];

  # Transitive dependency of gsoap (only supports static library builds)
  env.NIX_LDFLAGS = "-lz";

  preConfigure = ''
    find . -mindepth 1 -maxdepth 1 -type f -name "patch*.sh" -print0 | while IFS= read -r -d ''' file; do
      patchShebangs "$file"
    done
  '';

  meta = {
    description = "Toolkit for Http-based file management";

    longDescription = "Davix is a toolkit designed for file
    operations with Http based protocols (WebDav, Amazon S3, ...).
    Davix provides an API and a set of command line tools";

    homepage = "https://github.com/cern-fts/davix";

    changelog = "https://github.com/cern-fts/davix/blob/R_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }/RELEASE-NOTES.md";

    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ adev ];
    platforms = lib.platforms.all;
  };
})
