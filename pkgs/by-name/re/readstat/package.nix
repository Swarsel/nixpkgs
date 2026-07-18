{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "readstat";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "WizardMac";
    repo = "ReadStat";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-4lRJgZPB2gfaQ9fQKvDDpGhy1eDNT/nT1QmeZlCmCis=";
  };

  patches = [
    # Remove `gettext` requirement
    # https://github.com/WizardMac/ReadStat/issues/341
    (fetchpatch {
      hash = "sha256-k1yeplrx3pFPl5qzLfsAaj+qunv1BqOZypA05xSolaQ=";
      url = "https://github.com/WizardMac/ReadStat/pull/342/commits/b5512b32d3b3c39e2f0c322df1339a3c61f73712.patch";
    })

    # Add (void) to remove -Wstrict-prototypes warnings
    (fetchpatch {
      hash = "sha256-nkaEgusylVu7NtzSzBklBuOnqO9qJPovf0qn9tTE6ls=";
      url = "https://github.com/WizardMac/ReadStat/commit/211c342a1cfe46fb7fb984730dd7a29ff4752f35.patch";
    })

    # Backport use-after-free:
    #   https://github.com/WizardMac/ReadStat/pull/298
    (fetchpatch {
      hash = "sha256-9hmuFa05b4JlxSzquIxXArOGhbi27A+3y5gH1IDg+R0=";
      url = "https://github.com/WizardMac/ReadStat/commit/718d49155e327471ed9bf4a8c157f849f285b46c.patch";
    })

    # fix stringop-truncation warning
    (fetchpatch {
      hash = "sha256-LZtdFdru2y89NvmLqa1sryhfzZX09jEeC2qWJpDS/kI=";
      url = "https://github.com/WizardMac/ReadStat/commit/43d4cdec6783b29d0f1d0ae9564507739cd27567.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    libtool
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Command-line tool (+ C library) for converting SAS, Stata, and SPSS files";
    homepage = "https://github.com/WizardMac/ReadStat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ swflint ];
    platforms = lib.platforms.all;
  };
})
