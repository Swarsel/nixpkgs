{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qqwing";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "stephenostermiller";
    repo = "qqwing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MYHPANQk4aUuDqUNxWPbqw45vweZ2bBcUcMTyEjcAOM=";
  };

  postPatch = ''
    patchShebangs --build build/src-first-comment.pl build/src_neaten.pl

    substituteInPlace build/cpp_configure.sh \
      --replace-fail "./configure" "./configure $configureFlags"
    substituteInPlace build/cpp_install.sh \
      --replace-fail "sudo " ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    perl
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
  ];

  buildFlags = [
    "cppcompile"
  ];

  meta = {
    description = "Sudoku generating and solving software";
    homepage = "https://qqwing.com";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.unix;
    mainProgram = "qqwing";
  };
})
