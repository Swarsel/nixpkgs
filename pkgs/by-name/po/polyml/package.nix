{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gmp,
  libffi,
  pkgsHostTarget,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "polyml";
  version = "5.9.2";

  src = fetchFromGitHub {
    owner = "polyml";
    repo = "polyml";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-dHP5XNoLcFIqASfZVWu3MtY3B3H66skEl8ohlwTGyyM=";
  };

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail 'AC_FUNC_ALLOCA' "AC_FUNC_ALLOCA
    AH_TEMPLATE([_Static_assert])
    AC_DEFINE([_Static_assert], [static_assert])
    "
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure.ac --replace-fail stdc++ c++
  '';

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libffi
    gmp
    pkgsHostTarget.stdenv.cc
  ];

  configureFlags = [
    "--enable-shared"
    "--with-system-libffi"
    "--with-gmp"
  ];

  doCheck = true;

  preInstall = ''
    substituteInPlace polyc \
      --replace-fail "LINK=\"$CXX\"" "LINK=\"${lib.getExe' pkgsHostTarget.stdenv.cc "c++"}\""
  '';

  __structuredAttrs = true;

  meta = {
    description = "Standard ML compiler and interpreter";

    longDescription = ''
      Poly/ML is a full implementation of Standard ML.
    '';

    homepage = "https://www.polyml.org/";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ sempiternal-aurora ];
    platforms = with lib.platforms; (linux ++ darwin);
    # Broken as make target `polyimport.o` requires running code
    # compiled by the cross-compiler
    broken = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
  };
})
