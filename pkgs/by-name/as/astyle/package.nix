{
  lib,
  stdenv,
  fetchurl,
  cmake,
  versionCheckHook,
  asLibrary ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astyle";
  version = "3.6.17";

  src = fetchurl {
    url = "mirror://sourceforge/astyle/astyle-${finalAttrs.version}.tar.bz2";
    hash = "sha256-7cg5uAB35g7VeGtjlNRCtOsQFWzL3VlEtLNg4SWvs+E=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = lib.optional asLibrary [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  postInstall = lib.optionalString asLibrary ''
    install -Dm444 ../src/astyle.h $out/include/astyle.h
  '';

  doInstallCheck = !asLibrary;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # upstream repo includes a build/ directory
  cmakeBuildDir = "_build";

  meta = {
    description = "Source code indenter, formatter, and beautifier for C, C++, C# and Java";
    homepage = "https://astyle.sourceforge.net/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ carlossless ];
    platforms = lib.platforms.unix;
    mainProgram = "astyle";
  };
})
