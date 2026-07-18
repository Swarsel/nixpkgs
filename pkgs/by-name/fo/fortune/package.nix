{
  lib,
  stdenv,
  fetchurl,
  cmake,
  docbook-xsl-nons,
  fortune,
  libxslt,
  perl,
  recode,
  rinutils,
  withOffensive ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fortune-mod";
  version = "3.26.0";

  # We use fetchurl instead of fetchFromGitHub because the release pack has some
  # special files.
  src = fetchurl {
    url = "https://github.com/shlomif/fortune-mod/releases/download/fortune-mod-${finalAttrs.version}/fortune-mod-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-rE0UhsrJuZkEkQcTa5QQb+mKSurADsY1sUTEN2S//kw=";
  };

  patches = [
    (builtins.toFile "not-a-game.patch" ''
      diff --git a/CMakeLists.txt b/CMakeLists.txt
      index 865e855..5a59370 100644
      --- a/CMakeLists.txt
      +++ b/CMakeLists.txt
      @@ -154,7 +154,7 @@ ENDMACRO()
       my_exe(
           "fortune"
           "fortune/fortune.c"
      -    "games"
      +    "bin"
       )

       my_exe(
      --
    '')
  ];

  nativeBuildInputs = [
    cmake
    (perl.withPackages (p: [
      p.PathTiny
      p.AppXMLDocBookBuilder
    ]))
    rinutils
    libxslt
    docbook-xsl-nons
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    # "strfile" must be in PATH for cross-compiling builds.
    fortune
  ];

  buildInputs = [ recode ];

  cmakeFlags = [
    "-DLOCALDIR=${placeholder "out"}/share/fortunes"
  ]
  ++ lib.optional (!withOffensive) "-DNO_OFFENSIVE=true";

  postFixup = lib.optionalString (!withOffensive) ''
    rm $out/share/games/fortunes/men-women*
  '';

  meta = {
    description = "Program that displays a pseudorandom message from a database of quotations";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ vonfry ];
    platforms = lib.platforms.unix;
    mainProgram = "fortune";
  };
})
