{
  lib,
  stdenv,
  fetchurl,
  bc,
  coreutils,
  fetchpatch,
  gawk,
  ghostscript,
  gnugrep,
  gnused,
  libpng,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fig2dev";
  version = "3.2.9a";

  src = fetchurl {
    url = "mirror://sourceforge/mcj/fig2dev-${finalAttrs.version}.tar.xz";
    hash = "sha256-YeGFOTF2hS8DuQGzsFsZ+8Wtglj/FC89pucLG4NRMyY=";
  };

  patches = [
    ./CVE-2025-31162.patch
    ./CVE-2025-31163.patch

    # Fix build with gcc15
    # https://sourceforge.net/p/mcj/fig2dev/ci/ab4eee3cf0d0c1d861d64b9569a5d1497800cae2
    (fetchpatch {
      hash = "sha256-F6z0m3Ez9JpgZg+TjVjuIZhAyTMHodB7O/l8lDTOL54=";
      name = "fig2dev-prototypes.patch";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/media-gfx/fig2dev/files/fig2dev-3.2.9a-prototypes.patch?id=93644497325b6df7a17f8bd05ad0495607aa5c34";
    })
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ libpng ];
  configureFlags = [ "--enable-transfig" ];
  env.GSEXE = "${ghostscript}/bin/gs";

  postInstall = ''
    wrapProgram $out/bin/fig2ps2tex \
        --set PATH ${
          lib.makeBinPath [
            coreutils
            bc
            gnugrep
            gawk
          ]
        }
    wrapProgram $out/bin/pic2tpic \
        --set PATH ${lib.makeBinPath [ gnused ]}
  '';

  meta = {
    description = "Tool to convert Xfig files to other formats";
    homepage = "https://mcj.sourceforge.net/";
    license = lib.licenses.xfig;
    maintainers = with lib.maintainers; [ lesuisse ];
    platforms = lib.platforms.unix;
  };
})
