{
  lib,
  stdenv,
  fetchurl,
  base64,
  buildDunePackage,
  darwin,
  dune-site,
  fetchpatch,
  lem,
  linenoise,
  linksem,
  makeWrapper,
  menhir,
  menhirLib,
  omd,
  ott,
  pprint,
  yojson,
  version ? "0.20.1",
}:

buildDunePackage {
  inherit version;
  pname = "sail";

  src = fetchurl {
    url = "https://github.com/rems-project/sail/releases/download/${version}/sail-${version}.tbz";
    hash = "sha256-uoG416pXBeBAZAE6sgwAa4DG20T5UiWsT79gQil+UOs=";
  };

  patches = [
    # Compatibility with menhir ≥ 20220203
    (fetchpatch {
      hash = "sha256-+j0USd0Ish11aYEzYLRiqkydhUPQoD9RPNjRhQcyX9c=";
      url = "https://github.com/rems-project/sail/commit/446fb477c508853595ccc937ed60765aa685ae31.patch";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    ott
    menhir
    lem
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.sigtool
  ];

  propagatedBuildInputs = [
    base64
    omd
    dune-site
    linenoise
    menhirLib
    pprint
    linksem
    yojson
  ];

  preBuild = ''
    rm -r aarch*  # Remove code derived from non-bsd2 arm spec
    rm -r snapshots  # Some of this might be derived from stuff in the aarch dir, it builds fine without it
  '';

  # `buildDunePackage` only builds the [pname] package
  # This doesnt work in this case, as sail includes multiple packages in the same source tree
  buildPhase = ''
    runHook preBuild
    dune build --release ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    dune runtest ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    dune install --prefix $out --libdir $OCAMLFIND_DESTDIR
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/sail --set SAIL_DIR $out/share/sail
  '';

  meta = {
    description = "Language for describing the instruction-set architecture (ISA) semantics of processors";
    homepage = "https://github.com/rems-project/sail";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
