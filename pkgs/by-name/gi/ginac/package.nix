{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  cln,
  gccStdenv,
  gmp,
  pkg-config,
  python3,
  readline,
}:

gccStdenv.mkDerivation (finalAttrs: {
  pname = "ginac";
  version = "1.8.10";

  src = fetchurl {
    url = "https://www.ginac.de/ginac-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-bKwZc6UyXeC5vLjjkpiK6V+8N6pmwPHx07jmTAjOwbk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [ readline ] ++ lib.optional stdenv.hostPlatform.isDarwin gmp;
  propagatedBuildInputs = [ cln ];
  configureFlags = [ "--disable-rpath" ];

  preConfigure = ''
    patchShebangs ginsh
  '';

  passthru.tests.example = callPackage ./ginac-example-test.nix { ginac = finalAttrs.finalPackage; };

  meta = {
    description = "GiNaC C++ library for symbolic manipulations";
    homepage = "https://www.ginac.de/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
