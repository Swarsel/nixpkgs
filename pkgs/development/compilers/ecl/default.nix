{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  boehmgc,
  clang,
  fetchpatch,
  gcc,
  gmp,
  libffi,
  libtool,
  makeWrapper,
  mpfr,
  sbcl,
  texinfo,
  noUnicode ? false,
  threadSupport ? true,
  useBoehmgc ? false,
}:

let
  cc = if stdenv.cc.isClang then clang else gcc;
in
stdenv.mkDerivation rec {
  pname = "ecl";
  version = "26.5.5";

  src = fetchurl {
    url = "https://common-lisp.net/project/ecl/static/files/release/ecl-${version}.tgz";
    hash = "sha256-oBpbzajFtz5Z3aNJT9E+X+xdtqodrXgsPMO7V/FjNDU=";
  };

  nativeBuildInputs = [
    libtool
    autoconf
    automake
    texinfo
    makeWrapper
  ];

  propagatedBuildInputs = [
    libffi
    gmp
    mpfr
    cc
    # replaces ecl's own gc which other packages can depend on, thus propagated
  ]
  ++ lib.optionals useBoehmgc [
    # replaces ecl's own gc which other packages can depend on, thus propagated
    boehmgc
  ];

  configureFlags = [
    (if threadSupport then "--enable-threads" else "--disable-threads")
    "--with-gmp-incdir=${lib.getDev gmp}/include"
    "--with-gmp-libdir=${lib.getLib gmp}/lib"
    "--with-libffi-incdir=${lib.getDev libffi}/include"
    "--with-libffi-libdir=${lib.getLib libffi}/lib"
  ]
  ++ lib.optionals useBoehmgc [
    "--with-libgc-incdir=${lib.getDev boehmgc}/include"
    "--with-libgc-libdir=${lib.getLib boehmgc}/lib"
  ]
  ++ lib.optional (!noUnicode) "--enable-unicode";

  postInstall = ''
    sed -e 's/@[-a-zA-Z_]*@//g' -i $out/bin/ecl-config
    wrapProgram "$out/bin/ecl" --prefix PATH ':' "${
      lib.makeBinPath [
        cc # for the C compiler
        cc.bintools.bintools # for ar
      ]
    }"
  '';

  # ECL’s ‘make check’ only works after install, making it a de-facto
  # installCheck.
  doInstallCheck = true;
  hardeningDisable = [ "format" ];
  installCheckTarget = "check";
  # ECL is used as a bootstrap compiler for SBCL.
  passthru.tests.sbcl = sbcl;

  meta = {
    description = "Lisp implementation aiming to be small, fast and easy to embed";
    homepage = "https://common-lisp.net/project/ecl/";
    changelog = "https://gitlab.com/embeddable-common-lisp/ecl/-/raw/${version}/CHANGELOG";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "ecl";
    teams = [ lib.teams.lisp ];
  };
}
