{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nspr";
  version = "4.39";

  src = fetchurl {
    url = "mirror://mozilla/nspr/releases/v${finalAttrs.version}/src/nspr-${finalAttrs.version}.tar.gz";
    hash = "sha256-u9Au6HpVZ2Bjpj5byBngIn3iZmtHMHsqATRBTN9CNo4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-Makefile-use-SOURCE_DATE_EPOCH-for-reproducibility.patch
  ];

  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ]
  ++ lib.optional stdenv.hostPlatform.is64bit "--enable-64bit";

  env.HOST_CC = "cc";

  preConfigure = ''
    cd nspr
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure --replace '@executable_path/' "$out/lib/"
    substituteInPlace configure.in --replace '@executable_path/' "$out/lib/"
  '';

  postInstall = ''
    find $out -name "*.a" -delete
    moveToOutput share "$dev" # just aclocal
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  outputBin = "dev";

  passthru.tests = {
    inherit (nixosTests) firefox firefox-esr;
  };

  meta = {
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    homepage = "https://firefox-source-docs.mozilla.org/nspr/index.html";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      ajs124
      hexa
    ];

    platforms = lib.platforms.all;
  };
})
