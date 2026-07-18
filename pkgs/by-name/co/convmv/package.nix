{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "convmv";
  version = "2.06";

  src = fetchzip {
    url = "https://www.j3e.de/linux/convmv/convmv-${finalAttrs.version}.tar.gz";
    hash = "sha256-36UPh+eZBT/J2rkvOcHeqkVKSl4yO9GJp/BxWGDrgGU=";
  };

  outputs = [
    "bin"
    "man"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  buildInputs = [
    perl
    perlPackages.EncodeHanExtra
    perlPackages.EncodeIMAPUTF7
    perlPackages.EncodeJIS2K
  ];

  makeFlags = [
    "PREFIX=${placeholder "bin"}"
    "MANDIR=${placeholder "man"}/share/man"
  ];

  # testsuite.tar contains filenames that aren't valid UTF-8. Extraction of
  # testsuite.tar will fail as APFS enforces that filenames are valid UTF-8.
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = ''
    wrapProgram "$bin/bin/convmv" --prefix PERL5LIB : "$PERL5LIB"
  '';

  checkTarget = "test";
  dontPatchShebangs = true;

  prePatch =
    lib.optionalString finalAttrs.finalPackage.doCheck ''
      tar -xf testsuite.tar
    ''
    + ''
      patchShebangs --host .
    '';

  meta = {
    description = "Converts filenames from one encoding to another";

    license = with lib.licenses; [
      gpl2Only
      gpl3Only
    ];

    maintainers = with lib.maintainers; [ al3xtjames ];
    platforms = lib.platforms.unix;
    mainProgram = "convmv";
    downloadPage = "https://www.j3e.de/linux/convmv/";
  };
})
