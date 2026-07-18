{
  lib,
  fetchpatch,
  mkDerivation,
}:

mkDerivation {
  patches = [
    # Use `$AR` not hardcoded `ar`
    (fetchpatch {
      hash = "sha256-bigxJGbaf9mCmFXxLVzQpnUUaEMMDfF3eZkTXVzd6B8=";
      name = "use-ar-variable.patch";
      url = "https://marc.info/?l=openbsd-tech&m=171575284906018&q=raw";
    })
    ./netbsd-make-sinclude.patch
    # Support for a new NOBLIBSTATIC make variable
    (fetchpatch {
      hash = "sha256-p4izV6ZXkfgJud+ZZU1Wqr5qFuHUzE6qVXM7QnXvV3k=";
      includes = [ "share/mk/*" ];
      name = "nolibstatic-support.patch";
      url = "https://marc.info/?l=openbsd-tech&m=171972639411562&q=raw";
    })
  ];

  postPatch = ''
    sed -i -E \
      -e 's|/usr/lib|\$\{LIBDIR\}|' \
      share/mk/bsd.prog.mk

    substituteInPlace share/mk/bsd.obj.mk --replace-fail /bin/pwd pwd
  '';

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  installPhase = ''
    cp -r share/mk $out
  '';

  dontBuild = true;
  noCC = true;
  path = "share/mk";
  meta.platforms = lib.platforms.unix;
}
