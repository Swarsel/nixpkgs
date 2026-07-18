{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fixDarwinDylibNames,
  meson,
  ninja,
  pkg-config,
  python3,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fribidi";
  version = "1.0.16";

  # NOTE: Only URL tarball has "Have pre-generated man pages: true", which works-around upstream usage of some rare ancient `c2man` fossil application.
  src = fetchurl {
    url =
      with finalAttrs;
      "https://github.com/fribidi/fribidi/releases/download/v${version}/${pname}-${version}.tar.xz";

    sha256 = "sha256-GxzeWyNdQEeekb4vDoijCeMhTIq0cOyKJ0TYKlqeoFw=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs test
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  doCheck = true;
  nativeCheckInputs = [ python3 ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  passthru.tests = {
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "GNU implementation of the Unicode Bidirectional Algorithm (bidi)";
    homepage = "https://github.com/fribidi/fribidi";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
    mainProgram = "fribidi";
    pkgConfigModules = [ "fribidi" ];
  };
})
