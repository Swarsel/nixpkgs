{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fetchpatch,
  libintl,
  pkgsStatic,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "indent";
  version = "2.2.13";

  src = fetchurl {
    url = "mirror://gnu/indent/indent-${finalAttrs.version}.tar.gz";
    hash = "sha256-nmRjT8TOZ5eyBLy4iXzhT90KtIyldpb3h2fFnK5XgJU=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-OLXBlYTdEuFK8SIsyC5Xr/hHWlvXiRqY2h79w+H5pGk=";
      name = "CVE-2023-40305.part-1.patch";
      url = "https://git.savannah.gnu.org/cgit/indent.git/patch/?id=df4ab2d19e247d059e0025789ba513418073ab6f";
    })
    (fetchpatch {
      hash = "sha256-t+QF7N1aqQ28J2O8esZ2bc5K042cUuZR4MeMeuWIgPw=";
      name = "CVE-2023-40305.part-2.patch";
      url = "https://git.savannah.gnu.org/cgit/indent.git/patch/?id=2685cc0bef0200733b634932ea7399b6cf91b6d7";
    })
  ];

  # avoid https://savannah.gnu.org/bugs/?64751
  postPatch = ''
    sed -E -i '/output\/else-comment-2-br(-ce)?.c/d' regression/TEST
    sed -E -i 's/else-comment-2-br(-ce)?.c//g' regression/TEST
  '';

  strictDeps = true;
  nativeBuildInputs = [ texinfo ];
  buildInputs = [ libintl ];
  makeFlags = [ "AR=${stdenv.cc.targetPrefix}ar" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optional stdenv.cc.isClang "-Wno-implicit-function-declaration"
    ++ lib.optional (
      stdenv.cc.isClang && lib.versionAtLeast (lib.getVersion stdenv.cc) "13"
    ) "-Wno-unused-but-set-variable"
  );

  doCheck = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ]; # needed when cross-compiling
  hardeningDisable = [ "format" ];
  passthru.tests.static = pkgsStatic.indent;

  meta = {
    description = "Source code reformatter";
    homepage = "https://www.gnu.org/software/indent/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.mmahut ];
    platforms = lib.platforms.unix;
    mainProgram = "indent";
  };
})
