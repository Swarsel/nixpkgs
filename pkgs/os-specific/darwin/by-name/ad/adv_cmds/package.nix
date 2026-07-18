{
  lib,
  bison,
  fetchpatch2,
  flex,
  libxo,
  mkAppleDerivation,
  ncurses,
  pkg-config,
  sourceRelease,
  stdenvNoCC,
}:

let
  Libc = sourceRelease "Libc";
  libplatform = sourceRelease "libplatform";
  xnu = sourceRelease "xnu"; # Can’t use xnuHeaders because adv_cmds is a transitive dependency of xnuHeaders.

  privateHeaders = stdenvNoCC.mkDerivation {
    buildCommand = ''
      install -D -m644 -t "$out/include" \
        '${libplatform}/private/_simple.h' \
        '${Libc}/nls/FreeBSD/msgcat.h'

      install -D -m644 -t "$out/include/System/sys" \
        '${xnu}/bsd/sys/persona.h' \
        '${xnu}/bsd/sys/proc.h'

      install -D -m644 -t "$out/include/sys" \
        '${xnu}/bsd/sys/proc_private.h'
    '';

    name = "adv_cmds-deps-private-headers";
  };
in
mkAppleDerivation {
  outputs = [
    "out"
    "ps"
    "man"
  ];

  patches = [
    # We need `colldef` and `mklocale` due to building old locale data. Revert their removal.
    (fetchpatch2 {
      hash = "sha256-zDXYuYRak9t9ZnAacl3h5i36g7Law/fLdTKf+YDeRUk=";

      includes = [
        "colldef/*"
        "mklocale/*"
      ];

      revert = true;
      url = "https://github.com/apple-oss-distributions/adv_cmds/commit/6bed8737a34dbb54782a18f47dccf933a9967a12.patch?full_index=1";
    })
  ];

  postPatch = ''
    # Meson generators require using @BASENAME@ in the output.
    substituteInPlace mklocale/lex.l \
      --replace-fail y.tab.h yacc.tab.h
    substituteInPlace genwrap/lex.l \
      --replace-fail y.tab.h genwrap.tab.h
    substituteInPlace colldef/scan.l \
      --replace-fail y.tab.h parse.tab.h

    find localedef -name '*.c' -exec sed -e 's/parser.h/parser.tab.h/' -i {} \;

    # Fix paths to point to the store
    for file in genwrap.c genwrap.8; do
      substituteInPlace genwrap/$file \
        --replace-fail '/usr/local' "$out"
    done
  '';

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ];

  buildInputs = [
    libxo
    ncurses
  ];

  env.NIX_CFLAGS_COMPILE = "-I${privateHeaders}/include";

  postInstall = ''
    moveToOutput bin/ps "$ps"
    ln -s "$ps/bin/ps" "$out/bin/ps"
  '';

  releaseName = "adv_cmds";
  xcodeHash = "sha256-L27TYv2zdKx0WKTBgHSv9Q0FCwrW4o83EmtDyqFM1fs=";

  meta = {
    description = "Advanced commands package for Darwin";

    license = [
      lib.licenses.apsl10
      lib.licenses.apsl20
    ];
  };
}
