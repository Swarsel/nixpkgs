# This file defines the composition for R packages.

let
  importJSON = f: builtins.fromJSON (builtins.readFile f);

  biocPackagesGenerated = importJSON ./bioc-packages.json;
  biocAnnotationPackagesGenerated = importJSON ./bioc-annotation-packages.json;
  biocExperimentPackagesGenerated = importJSON ./bioc-experiment-packages.json;
  cranPackagesGenerated = importJSON ./cran-packages.json;
in

{
  R,
  overrides,
  pkgs,
}:

let
  inherit (pkgs)
    cacert
    fetchurl
    stdenv
    lib
    ;

  buildRPackage = pkgs.callPackage ./generic-builder.nix {
    inherit R;
    inherit (pkgs) gettext gfortran;
  };

  # Generates package templates given per-repository settings
  #
  # some packages, e.g. cncaGUI, require X running while installation,
  # so that we use xvfb-run if requireX is true.
  mkDerive =
    {
      mkHomepage,
      mkUrls,
      hydraPlatforms ? null,
    }:
    args:
    let
      hydraPlatforms' = hydraPlatforms;
    in
    lib.makeOverridable (
      {
        name,
        sha256,
        version,
        broken ? false,
        depends ? [ ],
        doCheck ? true,
        hydraPlatforms ? if hydraPlatforms' != null then hydraPlatforms' else platforms,
        maintainers ? [ ],
        platforms ? R.meta.platforms,
        requireX ? false,
      }:
      buildRPackage {
        inherit version;
        inherit doCheck requireX;
        pname = name;

        src = fetchurl {
          inherit sha256;
          urls = mkUrls (args // { inherit name version; });
        };

        nativeBuildInputs = depends;
        propagatedBuildInputs = depends;
        meta.broken = broken;
        meta.homepage = mkHomepage (args // { inherit name; });
        meta.hydraPlatforms = hydraPlatforms;
        meta.maintainers = maintainers;
        meta.platforms = platforms;
      }
    );

  # Templates for generating Bioconductor and CRAN packages
  # from the name, version, sha256, and optional per-package arguments above
  #
  deriveBioc = mkDerive {
    mkHomepage =
      { biocVersion, name }: "https://bioconductor.org/packages/${biocVersion}/bioc/html/${name}.html";

    mkUrls =
      {
        biocVersion,
        name,
        version,
      }:
      [
        "mirror://bioc/${biocVersion}/bioc/src/contrib/${name}_${version}.tar.gz"
        "mirror://bioc/${biocVersion}/bioc/src/contrib/Archive/${name}/${name}_${version}.tar.gz"
        "mirror://bioc/${biocVersion}/bioc/src/contrib/Archive/${name}_${version}.tar.gz"
      ];
  };
  deriveBiocAnn = mkDerive {
    hydraPlatforms = [ ];

    mkHomepage =
      { biocVersion, name }:
      "https://www.bioconductor.org/packages/${biocVersion}/data/annotation/html/${name}.html";

    mkUrls =
      {
        biocVersion,
        name,
        version,
      }:
      [
        "mirror://bioc/${biocVersion}/data/annotation/src/contrib/${name}_${version}.tar.gz"
      ];
  };
  deriveBiocExp = mkDerive {
    hydraPlatforms = [ ];

    mkHomepage =
      { biocVersion, name }:
      "https://www.bioconductor.org/packages/${biocVersion}/data/experiment/html/${name}.html";

    mkUrls =
      {
        biocVersion,
        name,
        version,
      }:
      [
        "mirror://bioc/${biocVersion}/data/experiment/src/contrib/${name}_${version}.tar.gz"
      ];
  };
  deriveCran = mkDerive {
    mkHomepage = { name }: "https://cran.r-project.org/web/packages/${name}/";

    mkUrls =
      { name, version }:
      [
        "mirror://cran/${name}_${version}.tar.gz"
        "mirror://cran/Archive/${name}/${name}_${version}.tar.gz"
      ];
  };

  # Overrides package definitions with nativeBuildInputs.
  # For example,
  #
  # overrideNativeBuildInputs {
  #   foo = [ pkgs.bar ]
  # } old
  #
  # results in
  #
  # {
  #   foo = old.foo.overrideAttrs (attrs: {
  #     nativeBuildInputs = attrs.nativeBuildInputs ++ [ pkgs.bar ];
  #   });
  # }
  overrideNativeBuildInputs =
    overrides: old:
    lib.mapAttrs (
      name: value:
      (builtins.getAttr name old).overrideAttrs (attrs: {
        nativeBuildInputs = attrs.nativeBuildInputs ++ value;
      })
    ) overrides;

  # Overrides package definitions with buildInputs.
  # For example,
  #
  # overrideBuildInputs {
  #   foo = [ pkgs.bar ]
  # } old
  #
  # results in
  #
  # {
  #   foo = old.foo.overrideAttrs (attrs: {
  #     buildInputs = attrs.buildInputs ++ [ pkgs.bar ];
  #   });
  # }
  overrideBuildInputs =
    overrides: old:
    lib.mapAttrs (
      name: value:
      (builtins.getAttr name old).overrideAttrs (attrs: {
        buildInputs = attrs.buildInputs ++ value;
      })
    ) overrides;

  # Overrides package definitions with maintainers.
  # For example,
  #
  # overrideMaintainers {
  #   foo = [ lib.maintainers.jsmith ]
  # } old
  #
  # results in
  #
  # {
  #   foo = old.foo.override {
  #     maintainers = [ lib.maintainers.jsmith ];
  #   };
  # }
  overrideMaintainers =
    overrides: old:
    lib.mapAttrs (
      name: value:
      (builtins.getAttr name old).override {
        maintainers = value;
      }
    ) overrides;

  # Overrides package definitions with new R dependencies.
  # For example,
  #
  # overrideRDepends {
  #   foo = [ self.bar ]
  # } old
  #
  # results in
  #
  # {
  #   foo = old.foo.overrideAttrs (attrs: {
  #     nativeBuildInputs = attrs.nativeBuildInputs ++ [ self.bar ];
  #     propagatedNativeBuildInputs = attrs.propagatedNativeBuildInputs ++ [ self.bar ];
  #   });
  # }
  overrideRDepends =
    overrides: old:
    lib.mapAttrs (
      name: value:
      (builtins.getAttr name old).overrideAttrs (attrs: {
        nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ value;
        propagatedNativeBuildInputs = (attrs.propagatedNativeBuildInputs or [ ]) ++ value;
      })
    ) overrides;

  # Overrides package definition requiring X running to install.
  # For example,
  #
  # overrideRequireX [
  #   "foo"
  # ] old
  #
  # results in
  #
  # {
  #   foo = old.foo.override {
  #     requireX = true;
  #   };
  # }
  overrideRequireX =
    packageNames: old:
    let
      nameValuePairs = map (name: {
        inherit name;

        value = (builtins.getAttr name old).override {
          requireX = true;
        };
      }) packageNames;
    in
    builtins.listToAttrs nameValuePairs;

  # Overrides package definition requiring a home directory to install or to
  # run tests.
  # For example,
  #
  # overrideRequireHome [
  #   "foo"
  # ] old
  #
  # results in
  #
  # {
  #   foo = old.foo.overrideAttrs (oldAttrs:  {
  #     preInstall = ''
  #       ${oldAttrs.preInstall or ""}
  #       export HOME=$(mktemp -d)
  #     '';
  #   });
  # }
  overrideRequireHome =
    packageNames: old:
    let
      nameValuePairs = map (name: {
        inherit name;

        value = (builtins.getAttr name old).overrideAttrs (oldAttrs: {
          preInstall = ''
            ${oldAttrs.preInstall or ""}
            export HOME=$(mktemp -d)
          '';
        });
      }) packageNames;
    in
    builtins.listToAttrs nameValuePairs;

  # Overrides package definition to skip check.
  # For example,
  #
  # overrideSkipCheck [
  #   "foo"
  # ] old
  #
  # results in
  #
  # {
  #   foo = old.foo.override {
  #     doCheck = false;
  #   };
  # }
  overrideSkipCheck =
    packageNames: old:
    let
      nameValuePairs = map (name: {
        inherit name;

        value = (builtins.getAttr name old).override {
          doCheck = false;
        };
      }) packageNames;
    in
    builtins.listToAttrs nameValuePairs;

  # Overrides package definition to mark it broken.
  # For example,
  #
  # overrideBroken [
  #   "foo"
  # ] old
  #
  # results in
  #
  # {
  #   foo = old.foo.override {
  #     broken = true;
  #   };
  # }
  overrideBroken =
    packageNames: old:
    let
      nameValuePairs = map (name: {
        inherit name;

        value = (builtins.getAttr name old).override {
          broken = true;
        };
      }) packageNames;
    in
    builtins.listToAttrs nameValuePairs;

  defaultOverrides =
    old: new:
    let
      old0 = old;
    in
    let
      old1 = old0 // (overrideRequireX packagesRequiringX old0);
      old2 = old1 // (overrideRequireHome packagesRequiringHome old1);
      old3 = old2 // (overrideSkipCheck packagesToSkipCheck old2);
      old4 = old3 // (overrideRDepends packagesWithRDepends old3);
      old5 = old4 // (overrideNativeBuildInputs packagesWithNativeBuildInputs old4);
      old6 = old5 // (overrideBuildInputs packagesWithBuildInputs old5);
      old7 = old6 // (overrideBroken brokenPackages old6);
      old8 = old7 // (overrideMaintainers packagesWithMaintainers old7);
      old = old8;
    in
    old // (otherOverrides old new);

  # Recursive override pattern.
  # `_self` is a collection of packages;
  # `self` is `_self` with overridden packages;
  # packages in `_self` may depends on overridden packages.
  self = (defaultOverrides _self self) // overrides;
  _self = {
    inherit buildRPackage;
  }
  // mkPackageSet deriveBioc biocPackagesGenerated
  // mkPackageSet deriveBiocAnn biocAnnotationPackagesGenerated
  // mkPackageSet deriveBiocExp biocExperimentPackagesGenerated
  // mkPackageSet deriveCran cranPackagesGenerated;

  # Takes in a generated JSON file's imported contents
  # and transforms it by swapping each element of the depends array with the dependency's derivation
  # and passing this new object to the provided derive function
  mkPackageSet =
    derive: packagesJSON:
    lib.mapAttrs (
      k: v:
      derive packagesJSON.extraArgs (
        v // { depends = lib.map (name: builtins.getAttr name self) v.depends; }
      )
    ) packagesJSON.packages;

  # tweaks for the individual packages and "in self" follow

  packagesWithMaintainers = with lib.maintainers; {
    BiocManager = [ jbedo ];
    RQuantLib = [ kupac ];
    StructuralVariantAnnotation = [ jbedo ];
    XLConnect = [ b-rodrigues ];
    data_table = [ jbedo ];
    ggplot2 = [ jbedo ];
    iscream = [ jamespeapen ];
    svaNUMT = [ jbedo ];
    svaRetro = [ jbedo ];
  };

  packagesWithRDepends = {
    FactoMineR = [ self.car ];
    TriDimRegression = [ self.rstantools ];
    bayesdfa = [ self.rstantools ];
    bbmix = [ self.rstantools ];
    disbayes = [ self.rstantools ];
    gastempt = [ self.rstantools ];
    interactiveDisplay = [ self.BiocManager ];
    pander = [ self.codetools ];
    pliman = [ self.EBImage ];
    rmsb = [ self.rstantools ];
    spectralGraphTopology = [ self.CVXR ];
    survextrap = [ self.rstantools ];
    tipsae = [ self.rstantools ];
  };

  packagesWithNativeBuildInputs = {
    Apollonius = with pkgs; [
      pkg-config
      gmp.dev
      mpfr.dev
    ];

    BayesChange = [ pkgs.gsl ];
    BayesSAE = [ pkgs.gsl ];
    BayesVarSel = [ pkgs.gsl ];

    BayesXsrc = with pkgs; [
      readline.dev
      ncurses
      gsl
    ];

    BigDataStatMeth = [ pkgs.pkg-config ];
    BiocCheck = [ pkgs.which ];
    Biostrings = [ pkgs.zlib ];
    BitSeq = [ pkgs.zlib.dev ];

    Cairo = with pkgs; [
      libtiff
      libjpeg
      cairo.dev
      libxt.dev
      fontconfig.lib
    ];

    Cardinal = [ pkgs.which ];
    CellBarcode = [ pkgs.zlib ];
    ChemmineOB = [ pkgs.pkg-config ];
    CytoML = [ pkgs.libxml2.dev ];
    DEploid = [ pkgs.zlib.dev ];
    DEploid_utils = [ pkgs.zlib.dev ];

    DiffBind = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
    ];

    EMCluster = [ pkgs.lapack ];
    Formula = [ pkgs.gmp ];
    GLAD = [ pkgs.gsl ];
    GPBayes = [ pkgs.gsl ];
    GeneralizedWendland = [ pkgs.gsl ];
    HiCParser = [ pkgs.zlib ];
    HiCseg = [ pkgs.gsl ];

    HilbertVisGUI = with pkgs; [
      pkg-config
      which
    ];

    JavaGD = [ pkgs.jdk ];
    KFKSDS = [ pkgs.gsl ];
    KSgeneral = with pkgs; [ pkg-config ];
    LOMAR = [ pkgs.gmp.dev ];
    Libra = [ pkgs.gsl ];

    MAGEE = [
      pkgs.zlib.dev
      pkgs.bzip2.dev
    ];

    ModelMetrics = lib.optional stdenv.hostPlatform.isDarwin pkgs.llvmPackages.openmp;
    NanoMethViz = [ pkgs.zlib.dev ];
    PEPBVS = [ pkgs.gsl ];
    PICS = [ pkgs.gsl ];
    PKI = [ pkgs.openssl.dev ];
    QF = [ pkgs.gsl ];

    R2SWF = with pkgs; [
      zlib
      libpng
      freetype.dev
    ];

    RAppArmor = [ pkgs.libapparmor ];
    RDieHarder = [ pkgs.gsl ];
    RGtk2 = [ pkgs.gtk2.dev ];
    RJMCMCNucleosomes = [ pkgs.gsl ];

    RMySQL = with pkgs; [
      zlib
      libmysqlclient
      openssl.dev
    ];

    RNetCDF = with pkgs; [
      netcdf
      udunits
    ];

    RNifti = with pkgs; [ zlib.dev ];
    RNiftyReg = with pkgs; [ zlib.dev ];
    RODBC = [ pkgs.libiodbc ];

    RPesto = with pkgs; [
      cargo
      rustc
    ];

    RPostgreSQL = with pkgs; [ libpq.pg_config ];

    RProtoBuf = with pkgs; [
      protobuf
      abseil-cpp.dev
    ];

    RSclient = [ pkgs.openssl.dev ];

    RVowpalWabbit = with pkgs; [
      zlib.dev
      boost
    ];

    RationalMatrix = [
      pkgs.pkg-config
      pkgs.gmp.dev
    ];

    Rbwa = [ pkgs.zlib.dev ];
    RcppCNPy = [ pkgs.zlib.dev ];

    RcppCWB = [
      pkgs.pkg-config
      pkgs.pcre2
    ];

    RcppDPR = [ pkgs.gsl ];
    RcppGSL = [ pkgs.gsl ];
    RcppMeCab = [ pkgs.pkg-config ];

    RcppPlanc = with pkgs; [
      which
      cmake
      pkg-config
    ];

    RcppZiggurat = [ pkgs.gsl ];
    Rglpk = [ pkgs.glpk ];

    Rhdf5lib = with pkgs; [
      cmake
    ];

    Rhisat2 = [
      pkgs.which
      pkgs.hostname
    ];

    Rhpc = with pkgs; [
      zlib
      bzip2.dev
      icu
      xz.dev
      mpi
      pcre.dev
    ];

    Rhtslib = with pkgs; [
      zlib.dev
      automake
      autoconf
      bzip2.dev
      xz.dev
      curl.dev
    ];

    Rigraphlib = [ pkgs.cmake ];
    Rlibeemd = [ pkgs.gsl ];

    Rmpfr = with pkgs; [
      gmp
      mpfr.dev
    ];

    Rmpi = with pkgs; [
      mpi.dev
      prrte.dev
    ];

    Rpoppler = [ pkgs.poppler ];

    Rsamtools = with pkgs; [
      zlib.dev
      curl.dev
      bzip2
      xz
    ];

    Rserve = [ pkgs.openssl ];
    Rssa = [ pkgs.fftw.dev ];
    Rsubbotools = [ pkgs.gsl ];
    Rsubread = [ pkgs.zlib.dev ];
    Rsymphony = [ pkgs.pkg-config ];

    SAVE = with pkgs; [
      zlib
      bzip2
      icu
      xz
      pcre
    ];

    SQLFormatteR = with pkgs; [
      cargo
      rustc
    ];

    SemiCompRisks = [ pkgs.gsl ];
    ShortRead = [ pkgs.zlib.dev ];
    SimInf = [ pkgs.gsl ];
    SymTS = [ pkgs.gsl ];
    TAQMNGR = [ pkgs.zlib.dev ];
    TDA = [ pkgs.gmp ];
    V8 = [ pkgs.nodejs-slim_22.libv8 ]; # when unpinning the version, don't forget about the other usages later
    VBLPCM = [ pkgs.gsl ];

    XBRL = with pkgs; [
      zlib
      libxml2.dev
    ];

    XML = with pkgs; [
      libtool
      libxml2.dev
      xmlsec
      libxslt
    ];

    XVector = [ pkgs.zlib.dev ];
    abn = [ pkgs.gsl ];
    adimpro = [ pkgs.imagemagick ];
    affyPLM = [ pkgs.zlib.dev ];
    affyio = [ pkgs.zlib.dev ];

    alcyon = with pkgs; [
      cmake
      which
    ];

    animation = [ pkgs.which ];
    apcf = with pkgs; [ geos ];

    arcgisgeocode = with pkgs; [
      cargo
      rustc
    ];

    arcgisplaces = with pkgs; [
      pkg-config
      openssl.dev
      cargo
      rustc
    ];

    arcgisutils = with pkgs; [
      cargo
      rustc
    ];

    arcpbf = with pkgs; [
      cargo
      rustc
    ];

    arrow =
      with pkgs;
      [
        pkg-config
        cmake
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ intltool ];

    astgrepr = with pkgs; [
      cargo
      rustc
    ];

    audio = [ pkgs.portaudio ];

    awdb = with pkgs; [
      cargo
      rustc
    ];

    b32 = with pkgs; [
      cargo
      rustc
    ];

    bigGP = [ pkgs.mpi ];

    bigrquerystorage = with pkgs; [
      grpc
      protobuf
      which
    ];

    bio3d = [ pkgs.zlib ];

    bioacoustics = [
      pkgs.fftw.dev
      pkgs.cmake
    ];

    blosc = [ pkgs.pkg-config ];
    bnpmr = [ pkgs.gsl ];
    cairoDevice = [ pkgs.gtk2.dev ];

    caugi = with pkgs; [
      cargo
      rustc
    ];

    caviarpd = with pkgs; [
      cargo
      rustc
    ];

    chebpol = [ pkgs.fftw.dev ];

    ciflyr = with pkgs; [
      cargo
      rustc
    ];

    cit = [ pkgs.gsl ];
    clarabel = [ pkgs.cargo ];
    cld3 = [ pkgs.protobuf ];
    clustermq = [ pkgs.zeromq ];

    cpp11bigwig = with pkgs; [
      zlib.dev
      curl.dev
    ];

    cpp11qpdf = with pkgs; [
      zlib.dev
      libjpeg
    ];

    crc32c = [
      pkgs.which
      pkgs.cmake
    ];

    curl = [ pkgs.curl.dev ];

    data_table =
      with pkgs;
      [
        pkg-config
        zlib.dev
      ]
      ++ lib.optional stdenv.hostPlatform.isDarwin pkgs.llvmPackages.openmp;

    datefixR = with pkgs; [
      cargo
      rustc
    ];

    devEMF = with pkgs; [ libxft.dev ];
    diseq = [ pkgs.gsl ];

    diversitree = with pkgs; [
      gsl
      fftw
    ];

    dynr = [ pkgs.gsl ];
    eaf = [ pkgs.gsl ];
    exactextractr = [ pkgs.geos ];
    fRLR = [ pkgs.gsl ];

    fangs = with pkgs; [
      cargo
      rustc
    ];

    fastgeojson = with pkgs; [
      cargo
      rustc
    ];

    fastpng = [ pkgs.zlib.dev ];

    fcl = with pkgs; [
      cargo
      rustc
    ];

    fftw = [ pkgs.fftw.dev ];

    fftwtools = with pkgs; [
      fftw.dev
      pkg-config
    ];

    fingerPro = [ pkgs.gsl ];

    fio = with pkgs; [
      cargo
      rustc
    ];

    flint = with pkgs; [
      pkg-config
      gmp.dev
      mpfr.dev
      flint
    ];

    flowPeaks = [ pkgs.gsl ];
    frailtyMMpen = [ pkgs.gsl ];

    fru = with pkgs; [
      cargo
      rustc
    ];

    gadjid = with pkgs; [
      cargo
      rustc
    ];

    gamstransfer = [ pkgs.zlib ];
    gdalcubes = [ pkgs.pkg-config ];
    gdalraster = [ pkgs.pkg-config ];

    gdtools =
      with pkgs;
      [
        cairo.dev
        fontconfig.lib
        freetype.dev
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        expat
        libxdmcp
      ];

    gert = [ pkgs.libgit2 ];
    ggiraph = [ pkgs.libpng.dev ];
    gglinedensity = [ pkgs.cargo ];

    git2r = with pkgs; [
      zlib.dev
      openssl.dev
      libssh2.dev
      libgit2
      pkg-config
    ];

    glpkAPI = with pkgs; [
      gmp
      glpk
    ];

    gmapR = [ pkgs.zlib.dev ];
    gmp = [ pkgs.gmp.dev ];
    graphscan = [ pkgs.gsl ];
    gsl = [ pkgs.gsl ];
    gslnls = [ pkgs.gsl ];

    h3o = with pkgs; [
      cargo
      rustc
    ];

    h5vc = with pkgs; [
      zlib.dev
      bzip2.dev
      xz.dev
    ];

    hSDM = [ pkgs.gsl ];
    harbinger = [ pkgs.glibcLocales ];
    haven = with pkgs; [ zlib.dev ];

    heck = with pkgs; [
      cargo
      rustc
    ];

    hellorust = [ pkgs.cargo ];
    hgwrr = [ pkgs.gsl ];

    highs = [
      pkgs.which
      pkgs.cmake
    ];

    httpgd = with pkgs; [ cairo.dev ];
    httpuv = [ pkgs.zlib.dev ];

    hypergeo2 = with pkgs; [
      gmp.dev
      mpfr.dev
      pkg-config
    ];

    iBMQ = [ pkgs.gsl ];

    image_CannyEdges = with pkgs; [
      fftw.dev
      libpng.dev
    ];

    imager = [ pkgs.libx11.dev ];
    imbibe = [ pkgs.zlib.dev ];
    immunoClust = [ pkgs.gsl ];
    interpolation = [ pkgs.pkg-config ];

    iscream = with pkgs; [
      pkg-config
      which
    ];

    jSDM = [ pkgs.gsl ];
    jack = [ pkgs.pkg-config ];
    jpeg = [ pkgs.libjpeg.dev ];
    jqr = [ pkgs.jq.dev ];
    kza = [ pkgs.fftw.dev ];
    leidenAlg = [ pkgs.gmp.dev ];
    libdeflate = [ pkgs.cmake ];
    libstable4u = [ pkgs.gsl ];
    littler = [ pkgs.libdeflate ];

    lpsymphony = with pkgs; [
      pkg-config
      gfortran
      gettext
    ];

    lwgeom = with pkgs; [
      proj
      geos
      gdal
    ];

    magick = [ pkgs.imagemagick.dev ];
    mcrPioda = [ pkgs.gsl ];
    mixlink = [ pkgs.gsl ];
    mixture = [ pkgs.gsl ];
    mmpca = [ pkgs.gsl ];
    monoreg = [ pkgs.gsl ];
    mvabund = [ pkgs.gsl ];
    mvst = [ pkgs.gsl ];
    mwaved = [ pkgs.fftw.dev ];

    mzR = with pkgs; [
      zlib
      netcdf
    ];

    n1qn1 = [ pkgs.gfortran ];

    nanonext = with pkgs; [
      mbedtls
      nng
    ];

    ncdf4 = [ pkgs.netcdf ];
    neojags = [ pkgs.jags ];

    nloptr = with pkgs; [
      nlopt
      pkg-config
    ];

    odbc = [ pkgs.unixodbc ];
    oligo = [ pkgs.zlib.dev ];
    opencv = [ pkgs.pkg-config ];

    otelsdk = with pkgs; [
      cmake
      which
      curl.dev
    ];

    pak = [ pkgs.curl.dev ];

    pander = with pkgs; [
      pandoc
      which
    ];

    parseLatex = [ pkgs.icu.dev ];
    pbdMPI = [ pkgs.mpi ];
    pbdPROF = [ pkgs.mpi ];
    pbdZMQ = [ pkgs.pkg-config ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ pkgs.which ];

    pcaL1 = [
      pkgs.pkg-config
      pkgs.clp
    ];

    pdftools = [ pkgs.poppler.dev ];
    phytools = [ pkgs.which ];
    png = [ pkgs.libpng.dev ];
    protolite = [ pkgs.protobuf ];

    prqlr = with pkgs; [
      cargo
      rustc
    ];

    qqconf = [ pkgs.pkg-config ];
    qspray = [ pkgs.pkg-config ];
    rGEDI = [ pkgs.gsl ];

    rJava = with pkgs; [
      stripJavaArchivesHook
      zlib
      bzip2.dev
      icu
      xz.dev
      zstd.dev
      pcre.dev
      jdk
      libzip
      libdeflate
    ];

    ragg = [ pkgs.pkg-config ];
    rapport = [ pkgs.which ];
    rapportools = [ pkgs.which ];
    ratioOfQsprays = [ pkgs.pkg-config ];

    rbedrock = [
      pkgs.zlib.dev
      pkgs.which
      pkgs.cmake
    ];

    rbm25 = with pkgs; [
      cargo
      rustc
    ];

    rcdd = [ pkgs.gmp.dev ];
    redux = [ pkgs.pkg-config ];
    reprex = [ pkgs.which ];

    resultant = with pkgs; [
      gmp.dev
      mpfr.dev
      pkg-config
    ];

    rgdal = with pkgs; [
      proj.dev
      gdal
    ];

    rgeos = [ pkgs.geos ];
    rhdf5 = [ pkgs.zlib ];
    ridge = [ pkgs.gsl ];
    rjags = [ pkgs.jags ];
    rlas = [ pkgs.pkg-config ];

    rmatio = [
      pkgs.zlib.dev
      pkgs.pkg-config
    ];

    rnetcarto = [ pkgs.gsl ];

    roxigraph = with pkgs; [
      cargo
      rustc
    ];

    rpanel = [ pkgs.tclPackages.bwidget ];
    rrd = [ pkgs.pkg-config ];

    rsamplr = with pkgs; [
      cargo
      rustc
    ];

    rsbml = [ pkgs.pkg-config ];

    rshift = with pkgs; [
      cargo
      rustc
    ];

    rsvg = [ pkgs.pkg-config ];

    rswipl = with pkgs; [
      cmake
      pkg-config
    ];

    rtracklayer = with pkgs; [
      zlib.dev
      curl.dev
    ];

    runjags = [ pkgs.jags ];
    rvg = [ pkgs.libpng.dev ];

    rzmq = with pkgs; [
      zeromq
      pkg-config
    ];

    s2 = [ pkgs.pkg-config ];

    salso = with pkgs; [
      cargo
      rustc
    ];

    scorematchingad = [ pkgs.cmake ];

    sdcTable = with pkgs; [
      gmp
      glpk
    ];

    seewave = with pkgs; [
      fftw.dev
      libsndfile.dev
    ];

    seqinr = [ pkgs.zlib.dev ];

    seqminer = with pkgs; [
      zlib.dev
      bzip2
    ];

    sf = with pkgs; [
      gdal
      proj
      geos
      libtiff
      curl
    ];

    showtext = with pkgs; [
      zlib
      libpng
      icu
      freetype.dev
    ];

    simplexreg = [ pkgs.gsl ];
    smam = [ pkgs.gsl ];

    smcryptoR = with pkgs; [
      cargo
      rustc
      which
    ];

    snpStats = [ pkgs.zlib.dev ];

    socratadata = with pkgs; [
      cargo
      rustc
    ];

    spate = [ pkgs.fftw.dev ];
    sphereTessellation = [ pkgs.pkg-config ];
    ssanv = [ pkgs.proj ];
    strawr = with pkgs; [ curl.dev ];
    string2path = [ pkgs.cargo ];
    stringi = [ pkgs.icu.dev ];
    stsm = [ pkgs.gsl ];
    survSNP = [ pkgs.gsl ];
    surveyvoi = [ pkgs.pkg-config ];
    svglite = [ pkgs.libpng.dev ];
    symbolicQspray = [ pkgs.pkg-config ];

    sysfonts = with pkgs; [
      zlib
      libpng
      freetype.dev
    ];

    systemfonts = with pkgs; [
      fontconfig.dev
      freetype.dev
    ];

    tergo = with pkgs; [
      cargo
      rustc
    ];

    terra = with pkgs; [
      gdal
      proj
      geos
      netcdf
    ];

    tesseract = with pkgs; [
      tesseract
      leptonica
    ];

    textshaping = [ pkgs.pkg-config ];
    themetagenomics = [ pkgs.zlib.dev ];
    tiff = [ pkgs.libtiff.dev ];

    tinyimg = with pkgs; [
      cargo
      rustc
    ];

    tkrplot = with pkgs; [
      libx11
      tk.dev
    ];

    tok = with pkgs; [
      cargo
      rustc
    ];

    tomledit = with pkgs; [
      cargo
      rustc
    ];

    topicmodels = [ pkgs.gsl ];
    trackViewer = [ pkgs.zlib.dev ];

    udunits2 = with pkgs; [
      udunits
      expat
    ];

    unigd = [ pkgs.pkg-config ];
    units = [ pkgs.udunits ];

    unsum = with pkgs; [
      cargo
      rustc
    ];

    vapour = [ pkgs.pkg-config ];

    vcfppR = [
      pkgs.curl.dev
      pkgs.bzip2
      pkgs.zlib.dev
      pkgs.xz
    ];

    vdiffr = [ pkgs.libpng.dev ];

    watcher = with pkgs; [
      cmake
      which
    ];

    waysign = with pkgs; [
      cargo
      rustc
    ];

    webp = [ pkgs.pkg-config ];

    xactonomial = with pkgs; [
      cargo
      rustc
    ];

    xdvir = [ pkgs.freetype.dev ];
    xml2 = [ pkgs.libxml2.dev ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ pkgs.perl ];
    xslt = [ pkgs.pkg-config ];

    ymd = with pkgs; [
      cargo
      rustc
    ];

    yyjsonr = with pkgs; [ zlib.dev ];
  };

  packagesWithBuildInputs = {
    AMOUNTAIN = [ pkgs.gsl ];

    ArrayExpressHTS = with pkgs; [
      zlib.dev
      curl.dev
      which
    ];

    BNSP = [ pkgs.gsl ];
    BigDataStatMeth = [ pkgs.zlib ];
    CBN2Path = [ pkgs.gsl ];
    CLVTools = [ pkgs.gsl ];
    CNEr = with pkgs; [ zlib ];
    Cairo = [ pkgs.pkg-config ];

    ChemmineOB = with pkgs; [
      eigen
      openbabel
      zlib.dev
    ];

    DGP4LCF = [
      pkgs.lapack
      pkgs.blas
    ];

    DiffBind = with pkgs; [ zlib.dev ];
    DirichletMultinomial = with pkgs; [ gsl ];
    DropletUtils = [ pkgs.zlib.dev ];
    EHRmuse = [ pkgs.gsl.dev ];

    FLAMES = with pkgs; [
      zlib.dev
      bzip2.dev
      xz.dev
    ];

    GMMAT = with pkgs; [
      zlib.dev
      bzip2.dev
    ];

    GRAB = [ pkgs.zlib.dev ];

    GeoFIS = with pkgs; [
      mpfr.dev
      gmp.dev
    ];

    GrafGen = [ pkgs.zlib ];
    HDF5Array = [ pkgs.zlib.dev ];
    HiCDCPlus = [ pkgs.zlib.dev ];
    HilbertVisGUI = [ pkgs.gtkmm2.dev ];
    JMcmprsk = [ pkgs.gsl ];
    KSgeneral = [ pkgs.fftw.dev ];
    LCMCR = [ pkgs.gsl ];
    MedianaDesigner = [ pkgs.zlib.dev ];

    MethScope = with pkgs; [
      ncurses
      zlib.dev
    ];

    OpenCL = with pkgs; [
      opencl-clhpp
      ocl-icd
    ];

    PING = [ pkgs.gsl ];
    PROJ = [ pkgs.proj.dev ];
    PoissonBinomial = [ pkgs.fftw.dev ];
    PoissonMultinomial = [ pkgs.fftw.dev ];
    PopGenome = [ pkgs.zlib.dev ];

    QuasR = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
    ];

    R2SWF = [ pkgs.pkg-config ];
    RCurl = [ pkgs.curl.dev ];
    RGtk2 = [ pkgs.pkg-config ];
    RITCH = [ pkgs.zlib.dev ];
    RKHSMetaMod = [ pkgs.gsl ];
    RMariaDB = [ pkgs.libmysqlclient.dev ];
    RMark = [ pkgs.which ];
    RPostgres = with pkgs; [ libpq ];
    RProtoBuf = [ pkgs.pkg-config ];
    RPushbullet = [ pkgs.which ];

    RQuantLib = with pkgs; [
      quantlib.dev
      boost.dev
    ];

    Rarr = [ pkgs.zlib.dev ];
    Rbowtie = with pkgs; [ zlib.dev ];
    Rbowtie2 = [ pkgs.zlib.dev ];
    RcppAlgos = [ pkgs.gmp.dev ];
    RcppBigIntAlgos = [ pkgs.gmp.dev ];

    RcppCWB = with pkgs; [
      pcre.dev
      glib.dev
    ];

    RcppMeCab = [ pkgs.mecab ];

    RcppPlanc = with pkgs; [
      hwloc
      hdf5.dev
    ];

    Rfastp = with pkgs; [
      xz.dev
      bzip2.dev
      zlib.dev
    ];

    Rhdf5lib = with pkgs; [
      curl
      zlib.dev
    ];

    RmecabKo = [ pkgs.mecab ];
    Rmmquant = [ pkgs.zlib.dev ];
    RoBMA = [ pkgs.jags ];
    RoBSA = [ pkgs.jags ];
    Rpoppler = [ pkgs.pkg-config ];

    Rsymphony = with pkgs; [
      symphony
      doxygen
      graphviz
      subversion
      cgl
      clp
    ];

    Rwbo = [ pkgs.zlib.dev ];

    SICtools = with pkgs; [
      zlib.dev
      ncurses.dev
    ];

    SLmetrics = [ pkgs.zlib.dev ];
    SPARSEMODr = [ pkgs.gsl ];
    Signac = [ pkgs.zlib.dev ];

    SuperGauss = [
      pkgs.pkg-config
      pkgs.fftw.dev
    ];

    SynExtend = [ pkgs.zlib.dev ];

    TransView = with pkgs; [
      xz.dev
      bzip2.dev
      zlib.dev
    ];

    VariantAnnotation = with pkgs; [
      zlib.dev
      curl.dev
      bzip2.dev
      xz.dev
    ];

    XML = [ pkgs.pkg-config ];
    XYomics = [ pkgs.boost ];
    # sort -t '=' -k 2
    abn = [ pkgs.jags ];

    adbcpostgresql = with pkgs; [
      readline.dev
      zlib.dev
      openssl.dev
      libkrb5.dev
      openpam
      libpq
    ];

    adimpro = with pkgs; [
      which
      xdpyinfo
    ];

    apsimx = [ pkgs.which ];
    archive = [ pkgs.libarchive ];
    arrangements = with pkgs; [ gmp.dev ];

    asciicast = with pkgs; [
      bzip2.dev
      icu.dev
      libdeflate
      xz.dev
      zlib.dev
      zstd.dev
    ];

    bamsignals = with pkgs; [
      zlib.dev
      xz.dev
      bzip2
    ];

    baseline = [ pkgs.lapack ];
    bayesWatch = [ pkgs.boost.dev ];
    bbl = with pkgs; [ gsl ];
    bgx = [ pkgs.boost ];
    bigmemory = lib.optionals stdenv.hostPlatform.isLinux [ pkgs.libuuid.dev ];
    bigsnpr = [ pkgs.zlib.dev ];
    bio3d = with pkgs; [ zlib.dev ];
    blosc = [ pkgs.c-blosc ];
    cairoDevice = [ pkgs.pkg-config ];

    cartogramR = with pkgs; [
      fftw.dev
      pkg-config
    ];

    catSurv = [ pkgs.gsl ];
    ccfindR = [ pkgs.gsl ];
    chebpol = [ pkgs.pkg-config ];
    clustermq = [ pkgs.pkg-config ];
    coga = [ pkgs.gsl.dev ];
    crandep = [ pkgs.gsl ];

    csaw = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
      curl
    ];

    deepSNV = with pkgs; [
      xz.dev
      bzip2.dev
      zlib.dev
    ];

    diffHic = with pkgs; [
      xz.dev
      bzip2.dev
    ];

    divest = [ pkgs.zlib.dev ];
    econetwork = [ pkgs.gsl ];
    eds = [ pkgs.zlib.dev ];

    epialleleR = with pkgs; [
      xz.dev
      bzip2.dev
      zlib.dev
    ];

    excursions = [ pkgs.gsl ];
    fftw = [ pkgs.pkg-config ];
    flan = [ pkgs.gsl ];
    flowWorkspace = [ pkgs.zlib.dev ];
    fs = [ pkgs.libuv ];
    gaston = with pkgs; [ zlib.dev ];

    gdalcubes = with pkgs; [
      proj.dev
      gdal
      sqlite.dev
      netcdf
    ];

    gdalraster = with pkgs; [
      gdal
      proj.dev
      sqlite.dev
    ];

    gdtools = [ pkgs.pkg-config ];
    gfilogisreg = [ pkgs.gmp.dev ];
    gpg = [ pkgs.gpgme ];
    gpuMagic = [ pkgs.ocl-icd ];
    gridGraphics = [ pkgs.which ];
    hadron = [ pkgs.gsl ];
    hipread = [ pkgs.zlib.dev ];

    igraph = with pkgs; [
      gmp
      libxml2.dev
      glpk
    ];

    ijtiff = with pkgs; [
      libtiff
      libjpeg
      zlib
    ];

    image_textlinedetector = with pkgs; [
      pkg-config
      opencv
    ];

    interpolation = with pkgs; [
      gmp
      mpfr
    ];

    iscream = with pkgs; [
      bzip2.dev
      xz.dev
      zlib.dev
    ];

    island = [ pkgs.gsl.dev ];

    jack = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    jackalope = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
    ];

    jqr = [ pkgs.jq.out ];

    knowYourCG = with pkgs; [
      zlib.dev
      ncurses.dev
    ];

    kza = [ pkgs.pkg-config ];
    landsepi = [ pkgs.gsl ];
    largeList = [ pkgs.zlib.dev ];
    libstableR = [ pkgs.gsl ];
    lnmixsurv = [ pkgs.gsl.dev ];

    lpsymphony = with pkgs; [
      symphony
      cgl
      clp
    ];

    lwgeom = with pkgs; [
      pkg-config
      proj.dev
      sqlite.dev
    ];

    mBvs = [ pkgs.gsl.dev ];

    maftools = with pkgs; [
      zlib.dev
      bzip2
      xz.dev
    ];

    magick = [ pkgs.pkg-config ];
    mappoly = [ pkgs.zlib.dev ];
    markets = [ pkgs.gsl ];
    mashr = [ pkgs.gsl ];
    matchingMarkets = [ pkgs.zlib.dev ];

    methylKit = with pkgs; [
      zlib.dev
      bzip2.dev
      xz.dev
    ];

    milorGWAS = [ pkgs.zlib.dev ];

    mitoClone2 = with pkgs; [
      xz.dev
      bzip2.dev
      zlib.dev
    ];

    mixcat = [ pkgs.gsl ];

    multibridge = with pkgs; [
      pkg-config
      mpfr.dev
    ];

    mutscan = [ pkgs.zlib.dev ];
    mwaved = [ pkgs.pkg-config ];
    nat = [ pkgs.which ];
    nat_templatebrains = [ pkgs.which ];
    ncdfFlow = [ pkgs.zlib.dev ];
    ndjson = [ pkgs.zlib.dev ];
    odbc = [ pkgs.pkg-config ];
    openssl = [ pkgs.pkg-config ];

    otelsdk = with pkgs; [
      protobuf
      zlib.dev
    ];

    pbdZMQ = [ pkgs.zeromq ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ pkgs.darwin.binutils ];
    pdftools = [ pkgs.pkg-config ];
    pexm = [ pkgs.jags ];
    pgenlibr = [ pkgs.zlib.dev ];

    pliman = with pkgs; [
      fftw.dev
      libpng.dev
    ];

    podkat = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
    ];

    poisbinom = [ pkgs.fftw.dev ];
    pqsfinder = [ pkgs.boost ];
    proj4 = [ pkgs.proj.dev ];
    psbcGroup = [ pkgs.gsl.dev ];
    qckitfastq = [ pkgs.zlib.dev ];

    qpdf = with pkgs; [
      libjpeg.dev
      zlib.dev
    ];

    qqconf = [ pkgs.fftw.dev ];
    qrqc = [ pkgs.zlib.dev ];

    qspray = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    rDEA = [ pkgs.glpk ];

    rGEDI = with pkgs; [
      libgeotiff.dev
      libaec
      zlib.dev
      hdf5.dev
    ];

    rJPSGCS = [ pkgs.zlib.dev ];

    raer = with pkgs; [
      zlib.dev
      xz.dev
      bzip2.dev
    ];

    ragg =
      with pkgs;
      [
        freetype.dev
        libpng.dev
        libtiff.dev
        zlib.dev
        libjpeg.dev
        bzip2.dev
        libwebp
      ]
      ++ lib.optional stdenv.hostPlatform.isDarwin lerc.dev;

    ratioOfQsprays = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    ravetools = with pkgs; [
      pkg-config
      fftw.dev
    ];

    rawrr = [ pkgs.mono ];
    rcontroll = [ pkgs.gsl.dev ];
    redux = [ pkgs.hiredis ];

    registr = with pkgs; [
      icu.dev
      zlib.dev
      bzip2.dev
      xz.dev
      libdeflate
      zstd.dev
    ];

    rgl = with pkgs; [
      libGLU
      libGL
      libx11.dev
      freetype.dev
      libpng.dev
    ];

    rhdf5filters = with pkgs; [
      zlib.dev
      bzip2.dev
    ];

    rlas = with pkgs; [
      boost
      gdal
      proj
      sqlite
      geos
    ];

    rmumps = with pkgs; [ zlib.dev ];
    rrd = [ pkgs.rrdtool ];
    rsbml = [ pkgs.libsbml ];
    rsvg = [ pkgs.librsvg.dev ];

    rswipl = with pkgs; [
      ncurses.dev
      libxcrypt
      zlib.dev
    ];

    rtk = [ pkgs.zlib.dev ];
    rtmpt = [ pkgs.gsl ];

    s2 = with pkgs; [
      abseil-cpp
      openssl.dev
    ];

    saeMSPE = [ pkgs.gsl.dev ];

    sbrl = with pkgs; [
      gsl
      gmp.dev
    ];

    scModels = [ pkgs.mpfr.dev ];

    scPipe = with pkgs; [
      bzip2.dev
      xz.dev
      zlib.dev
    ];

    screenCounter = [ pkgs.zlib.dev ];
    seqTools = [ pkgs.zlib.dev ];

    seqbias = with pkgs; [
      zlib.dev
      bzip2.dev
      xz.dev
    ];

    sf = with pkgs; [
      pkg-config
      sqlite.dev
      proj.dev
    ];

    showtext = [ pkgs.pkg-config ];
    shrinkTVP = [ pkgs.gsl ];
    spFW = [ pkgs.fftw.dev ];
    spaMM = [ pkgs.gsl ];
    sparkwarc = [ pkgs.zlib.dev ];
    spate = [ pkgs.pkg-config ];
    specklestar = [ pkgs.fftw.dev ];

    sphereTessellation = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    spp = with pkgs; [ zlib.dev ];
    ssh = with pkgs; [ libssh ];
    stpphawkes = [ pkgs.gsl ];
    stringi = [ pkgs.pkg-config ];

    surveyvoi = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    svKomodo = [ pkgs.which ];

    symbolicQspray = with pkgs; [
      gmp.dev
      mpfr.dev
    ];

    symengine = with pkgs; [
      mpfr
      symengine
      flint
    ];

    sysfonts = [ pkgs.pkg-config ];
    systemfonts = [ pkgs.pkg-config ];

    tcltk2 = with pkgs; [
      tcl
      tk
    ];

    terra = with pkgs; [
      pkg-config
      sqlite.dev
      proj.dev
    ];

    tesseract = [ pkgs.pkg-config ];

    textshaping = with pkgs; [
      harfbuzz.dev
      freetype.dev
      fribidi
      libpng
    ];

    tfevents = [ pkgs.protobuf ];
    tidypopgen = [ pkgs.zlib.dev ];

    tikzDevice = with pkgs; [
      which
      texliveMedium
    ];

    transmogR = [ pkgs.zlib.dev ];
    ulid = [ pkgs.zlib.dev ];

    unigd =
      with pkgs;
      [
        cairo.dev
        libpng.dev
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        expat
        libxdmcp
      ];

    unrtf = with pkgs; [
      bzip2.dev
      icu.dev
      libdeflate
      xz.dev
      zlib.dev
      zstd.dev
    ];

    vapour = with pkgs; [
      proj.dev
      gdal
    ];

    vcfR = with pkgs; [ zlib.dev ];
    webp = [ pkgs.libwebp ];
    writexl = with pkgs; [ zlib.dev ];

    xslt =
      with pkgs;
      [
        libxslt
        libxml2
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ xz ];

    zlib = [ pkgs.zlib.dev ];
  };

  packagesRequiringX = [
    "analogueExtra"
    "AnalyzeFMRI"
    "AnnotLists"
    "asbio"
    "BCA"
    "biplotbootGUI"
    "cairoDevice"
    "cncaGUI"
    "CommunityCorrelogram"
    "dave"
    "DeducerPlugInExample"
    "DeducerPlugInScaling"
    "DeducerSpatial"
    "DeducerSurvival"
    "DeducerText"
    "Demerelate"
    "diveR"
    "dpa"
    "dynamicGraph"
    "EasyqpcR"
    "exactLoglinTest"
    "fisheyeR"
    "forams"
    "forensim"
    "GGEBiplotGUI"
    "gsubfn"
    "gWidgets2RGtk2"
    "gWidgets2tcltk"
    "HiveR"
    "ic50"
    "iClick"
    "iDynoR"
    "iplots"
    "likeLTD"
    "loon"
    "loon_ggplot"
    "loon_shiny"
    "loon_tourr"
    "Meth27QC"
    "mixsep"
    "multibiplotGUI"
    "OligoSpecificitySystem"
    "optbdmaeAT"
    "optrcdmaeAT"
    "paleoMAS"
    "RandomFields"
    "rfviz"
    "RclusTool"
    "RcmdrPlugin_coin"
    "RcmdrPlugin_FuzzyClust"
    "RcmdrPlugin_IPSUR"
    "RcmdrPlugin_lfstat"
    "RcmdrPlugin_PcaRobust"
    "RcmdrPlugin_plotByGroup"
    "RcmdrPlugin_pointG"
    "RcmdrPlugin_sampling"
    "RcmdrPlugin_SCDA"
    "RcmdrPlugin_SLC"
    "RcmdrPlugin_steepness"
    "rich"
    "RSurvey"
    "simba"
    "SimpleTable"
    "SOLOMON"
    "soptdmaeA"
    "strvalidator"
    "stylo"
    "SyNet"
    "switchboard"
    "tkImgR"
    "TTAinterfaceTrendAnalysis"
    "twiddler"
    "uHMM"
    "VecStatGraphs3D"
  ];

  packagesRequiringHome = [
    "aroma_affymetrix"
    "aroma_cn"
    "aroma_core"
    "avotrex"
    "beer"
    "ceramic"
    "connections"
    "covidmx"
    "ggiraph"
    "csodata"
    "DiceView"
    "facmodTS"
    "fwtraits"
    "gasanalyzer"
    "margaret"
    "MSnID"
    "OmnipathR"
    "orthGS"
    "pannotator"
    "precommit"
    "protGear"
    "PCRA"
    "PSCBS"
    "iemisc"
    "ready4"
    "red"
    "repmis"
    "R_cache"
    "R_filesets"
    "RKorAPClient"
    "R_rsp"
    "salso"
    "scholar"
    "SpatialDecon"
    "stepR"
    "styler"
    "tabs"
    "teal_code"
    "TreeTools"
    "TreeSearch"
    "PKbioanalysis"
    "ACNE"
    "APAlyzer"
    "BAT"
    "EstMix"
    "Patterns"
    "PECA"
    "Quartet"
    "ShinyQuickStarter"
    "TIN"
    "cfdnakit"
    "CaDrA"
    "GNOSIS"
    "TotalCopheneticIndex"
    "TreeDist"
    "biocthis"
    "calmate"
    "fgga"
    "fulltext"
    "dataverse"
    "immuneSIM"
    "mastif"
    "rdss"
    "shinymeta"
    "shinyobjects"
    "wppi"
    "pins"
    "CoTiMA"
    "TBRDist"
    "Rogue"
    "fixest"
    "paxtoolsr"
    "systemPipeShiny"
    "matlab2r"
    "GNOSIS"
  ];

  packagesToSkipCheck = [
    "MsDataHub" # tries to connect to ExperimentHub
    "Rmpi" # tries to run MPI processes
    "ReactomeContentService4R" # tries to connect to Reactome
    "PhIPData" # tries to download something from a DB
    "pbdMPI" # tries to run MPI processes
    "CTdata" # tries to connect to ExperimentHub
    "rfaRm" # tries to connect to Ebi
    "data_table" # fails to rename shared library before check
    "coMethDMR" # tries to connect to ExperimentHub
    "multiMiR" # tries to connect to DB
    "snapcount" # tries to connect to snaptron.cs.jhu.edu
  ];

  # Packages which cannot be installed due to lack of dependencies or other reasons.
  brokenPackages = [
    "av"
    "NetLogoR"
    "valse"
    "HierO"
    "HIBAG"
    "HiveR"
    "minired" # deprecated on CRAN

    # Impure network access during build
    "BulkSignalR"
    "waddR"
    "tiledb"
    "switchr"

    # ExperimentHub dependents, require net access during build
    "DuoClustering2018"
    "FieldEffectCrc"
    "GenomicDistributionsData"
    "hpar"
    "HDCytoData"
    "HMP16SData"
    "PANTHER_db"
    "RNAmodR_Data"
    "SCATEData"
    "SingleMoleculeFootprintingData"
    "TabulaMurisData"
    "benchmarkfdrData2019"
    "bodymapRat"
    "clustifyrdatahub"
    "CTexploreR"
    "depmap"
    "emtdata"
    "metaboliteIDmapping"
    "msigdb"
    "muscData"
    "org_Mxanthus_db"
    "scpdata"
    "signatureSearch"
    "nullrangesData"
  ];

  otherOverrides = old: new: {
    ACME = old.ACME.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # Avoid incompatible pointer type error
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -Wno-incompatible-pointer-types";
      };
    });

    AneuFinder = old.AneuFinder.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace src/utility.cpp src/densities.cpp src/loghmm.cpp src/scalehmm.cpp \
          --replace-fail "Calloc(" "R_Calloc(" \
          --replace-fail "Free(" "R_Free("
      '';
    });

    BigDataStatMeth = old.BigDataStatMeth.overrideAttrs (_: {
      preConfigure = "patchShebangs configure";
    });

    BiocParallel = old.BiocParallel.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE =
          attrs.env.NIX_CFLAGS_COMPILE
          + lib.optionalString stdenv.hostPlatform.isDarwin " -Wno-error=missing-template-arg-list-after-template-kw";
      };
    });

    Cairo = old.Cairo.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_LDFLAGS = "-lfontconfig";
      };
    });

    ChIPXpress = old.ChIPXpress.override { hydraPlatforms = [ ]; };

    ChemmineOB = old.ChemmineOB.overrideAttrs (attrs: {
      # pkg-config knows openbabel-3 without the .0
      # Eigen3 is also looked for in the wrong location
      # pointer was changed in newer version of openbabel:
      #   https://github.com/openbabel/openbabel/commit/305a6fd3183540e4a8ae1d79d10bf1860e6aa373
      postPatch = ''
        substituteInPlace configure \
          --replace-fail openbabel-3.0 openbabel-3
        substituteInPlace src/Makevars.in \
          --replace-fail "-I/usr/include/eigen3" "-I${pkgs.eigen}/include/eigen3"
        substituteInPlace src/ChemmineOB.cpp \
          --replace-fail "obsharedptr<" "std::shared_ptr<"
      '';

      # copied from fastnlo-toolkit:
      # None of our currently packaged versions of swig are C++17-friendly
      # Use a workaround from https://github.com/swig/swig/issues/1538
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE =
          (attrs.env.NIX_CFLAGS_COMPILE or "")
          + lib.optionalString stdenv.hostPlatform.isDarwin " -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES";
      };
    });

    Colossus = old.Colossus.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    Cyclops = old.Cyclops.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    FLAMES = old.FLAMES.overrideAttrs (attrs: {
      patches = [ ./patches/FLAMES.patch ];
    });

    FlexReg = old.FlexReg.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # needed to avoid "log limit exceeded" on Hydra
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -Wno-ignored-attributes";
      };

      # consumes a lot of resources in parallel
      enableParallelBuilding = false;
    });

    HilbertVis = old.HilbertVis.overrideAttrs (attrs: {
      hardeningDisable = [ "format" ];
    });

    HilbertVisGUI = old.HilbertVisGUI.overrideAttrs (attrs: {
      hardeningDisable = [ "format" ];
    });

    JavaGD = old.JavaGD.overrideAttrs (attrs: {
      preConfigure = ''
        export JAVA_CPPFLAGS=-I${pkgs.jdk}/include/
        export JAVA_HOME=${pkgs.jdk}
      '';
    });

    MANOR = old.MANOR.overrideAttrs (attrs: {
      hardeningDisable = [ "format" ];
    });

    ModelMetrics = old.ModelMetrics.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE =
          attrs.env.NIX_CFLAGS_COMPILE + lib.optionalString stdenv.hostPlatform.isDarwin " -fopenmp";
      };
    });

    NGCHM = old.NGCHM.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "inst/base.config/conf.d/01-server-protocol-scl.R" \
          --replace-fail \
          "/bin/hostname" "${lib.getBin pkgs.hostname}/bin/hostname"
      '';
    });

    OpenMx = old.OpenMx.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # needed to avoid "log limit exceeded" on Hydra
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -Wno-ignored-attributes";
      };

      preConfigure = ''
        patchShebangs configure
      '';
    });

    PICS = old.PICS.overrideAttrs (attrs: {
      postPatch = ''
        # https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2025/01/08#n2025-01-08
        substituteInPlace "src/segment.c" \
        --replace-fail "Calloc" "R_Calloc"
      '';
    });

    RAppArmor = old.RAppArmor.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        LIBAPPARMOR_HOME = pkgs.libapparmor;
      };
    });

    RBioFormats = old.RBioFormats.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "R/zzz.R" \
          --replace-fail '!file.exists(bf_jar)' 'FALSE' \
          --replace-fail \
          '.jpackage(pkg, lib.loc = lib, morePaths = c(jars, bf_jar))' \
          '.jpackage(pkg, lib.loc = lib, morePaths = union(jars, "${lib.getBin pkgs.bftools}/share/java/bioformats_package.jar"))' \
          --replace-fail 'bf_jar <-' 'stopifnot(bf_ver == "${pkgs.bftools.version}");bf_jar <-'
      '';

      # 1. Never download the jar file
      # 2. Use jar from pkgs.bftools instead
      # 3. Break the build if versions don't match
      propagatedBuildInputs = (attrs.propagatedBuildInputs or [ ]) ++ [ pkgs.bftools ];

      # Ensure that bftools version matches that in the package DESCRIPTION
      preInstall = ''
        rbf_version="$(sed  -n 's/^BioFormats: //p' DESCRIPTION)"
        bf_version="${pkgs.bftools.version}"
        if [ "$rbf_version" != "$bf_version" ]; then
           echo "BioFormats version mismatch detected!"
           echo "RBioformats needs: $rbf_version"
           echo "bftools provides: $bf_version"
           exit 1
        fi
      '';
    });

    RMySQL = old.RMySQL.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        MYSQL_DIR = "${pkgs.libmysqlclient}";
        NIX_CFLAGS_LINK = "-L${pkgs.libmysqlclient}/lib/mysql -lmysqlclient";
        PKGCONFIG_CFLAGS = "-I${pkgs.libmysqlclient.dev}/include/mysql";
      };

      preConfigure = ''
        patchShebangs configure
      '';
    });

    ROracle = old.ROracle.overrideAttrs (attrs: {
      configureFlags = [
        "--with-oci-lib=${pkgs.oracle-instantclient.lib}/lib"
        "--with-oci-inc=${pkgs.oracle-instantclient.dev}/include"
      ];
    });

    RPesto = old.RPesto.overrideAttrs (_: {
      preConfigure = "patchShebangs configure";
    });

    RProtoBuf = old.RProtoBuf.overrideAttrs (attrs: {
      configureFlags = [ "ac_cv_prog_cxx_cxx11=" ];
    });

    RVowpalWabbit = old.RVowpalWabbit.overrideAttrs (attrs: {
      configureFlags = [
        "--with-boost=${pkgs.boost.dev}"
        "--with-boost-libdir=${pkgs.boost.out}/lib"
      ];
    });

    RandomFieldsUtils = old.RandomFieldsUtils.override {
      platforms = lib.platforms.x86_64 ++ lib.platforms.x86;
    };

    Rbwa = old.Rbwa.overrideAttrs (attrs: {
      # Parallel build cleans up *.o before they can be packed in a library
      postPatch = ''
        substituteInPlace src/Makefile --replace-fail \
          "all:\$(PROG) ../inst/bwa clean" \
          "all:\$(PROG) ../inst/bwa"
      '';
    });

    RcppArmadillo = old.RcppArmadillo.overrideAttrs (attrs: {
      patchPhase = "patchShebangs configure";
    });

    RcppCGAL = old.RcppCGAL.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    RcppGetconf = old.RcppGetconf.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    RcppParallel = old.RcppParallel.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    Rdisop = old.Rdisop.overrideAttrs (_: {
      hardeningDisable = [ "format" ];
    });

    Rhdf5lib =
      let
        hdf5 = pkgs.hdf5.overrideAttrs (attrs: {
          buildInputs = attrs.buildInputs ++ [ pkgs.curl.dev ];
          cmakeFlags = attrs.cmakeFlags ++ [ "-DHDF5_ENABLE_ROS3_VFD:BOOL=TRUE" ];

          postInstall = attrs.postInstall or "" + ''
            cp src/libhdf5.settings $dev/lib
          '';
        });
      in
      old.Rhdf5lib.overrideAttrs (attrs: {
        patches = [ ./patches/Rhdf5lib.patch ];

        propagatedBuildInputs = attrs.propagatedBuildInputs ++ [
          hdf5.dev
          pkgs.libaec
        ];

        passthru.hdf5 = hdf5;
      });

    Rhisat2 = old.Rhisat2.overrideAttrs (attrs: {
      enableParallelBuilding = false;
    });

    Rhtslib = old.Rhtslib.overrideAttrs (attrs: {
      preConfigure = ''
        substituteInPlace R/zzz.R --replace-fail "-lcurl" "-L${pkgs.curl.out}/lib -lcurl"
      '';
    });

    Rmpfr = old.Rmpfr.overrideAttrs (attrs: {
      configureFlags = [
        "--with-mpfr-include=${pkgs.mpfr.dev}/include"
      ];
    });

    Rmpi = old.Rmpi.overrideAttrs (attrs: {
      configureFlags = [
        "--with-Rmpi-type=OPENMPI"
      ];
    });

    Rrdrand = old.Rrdrand.override { platforms = lib.platforms.x86_64 ++ lib.platforms.x86; };

    Rserve = old.Rserve.overrideAttrs (attrs: {
      patches = [ ./patches/Rserve.patch ];

      configureFlags = [
        "--with-server"
        "--with-client"
      ];
    });

    SAIGEgds = old.SAIGEgds.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -fpermissive";
      };
    });

    SICtools = old.SICtools.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace src/Makefile --replace-fail "-lcurses" "-lncurses"
      '';

      hardeningDisable = [ "format" ];
    });

    SQLFormatteR = old.SQLFormatteR.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    SamplerCompare = old.SamplerCompare.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKG_LIBS = "-L${pkgs.blas}/lib -lblas -L${pkgs.lapack}/lib -llapack";
      };
    });

    SpliceWiz = old.SpliceWiz.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    SynExtend = old.SynExtend.overrideAttrs (attrs: {
      # build might fail due to race condition
      enableParallelBuilding = false;
    });

    V8 = old.V8.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace configure \
          --replace-fail " -lv8_libplatform" ""
        # Bypass the test checking if pointer compression is needed
        substituteInPlace configure \
          --replace-fail "./pctest1" "true"
      '';

      env = (attrs.env or { }) // {
        R_MAKEVARS_SITE = lib.optionalString (pkgs.stdenv.system == "aarch64-linux") (
          pkgs.writeText "Makevars" ''
            CXX14PICFLAGS = -fPIC
          ''
        );
      };

      preConfigure = ''
        # when unpinning the version, don't forget about the other usage earlier
        export INCLUDE_DIR=${pkgs.nodejs-slim_22.libv8}/include
        export LIB_DIR=${pkgs.nodejs-slim_22.libv8}/lib
        patchShebangs configure
      '';
    });

    XLConnect =
      let
        poi-ooxml-full = fetchurl {
          hash = "sha256-xRsFFlXVjXTV64nn03NscFLCV09Dx52wyKg60hb23Tc=";
          url = "https://repo1.maven.org/maven2/org/apache/poi/poi-ooxml-full/5.4.1/poi-ooxml-full-5.4.1.jar";
        };
        poi-ooxml = fetchurl {
          hash = "sha256-/SAMnm901wQWCpfp1SBBmV7YdDlFRTAAHt2SBojxn1M=";
          url = "https://repo1.maven.org/maven2/org/apache/poi/poi-ooxml/5.4.1/poi-ooxml-5.4.1.jar";
        };
        poi = fetchurl {
          hash = "sha256-2lq/QtpGBMWnvKOJVq9unW8ZbZttTLfqvuT0gLWA1QU=";
          url = "https://repo1.maven.org/maven2/org/apache/poi/poi/5.4.1/poi-5.4.1.jar";
        };
        commons-compress = fetchurl {
          hash = "sha256-KT2A9UtTa3QJXc1+o88KKbv8NAJRkoEzJJX0Qg03DRY=";
          url = "https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.27.1/commons-compress-1.27.1.jar";
        };
        commons-lang3 = fetchurl {
          hash = "sha256-CHCd101gK3Bc5AF9JlRCEAVqS6WD1bIMCTc0Bv56APg=";
          url = "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.16.0/commons-lang3-3.16.0.jar";
        };
        xmlbeans = fetchurl {
          hash = "sha256-bMado7TTW4PF5HfNTauiBORBCYM+NK8rmoosh4gomRc=";
          url = "https://repo1.maven.org/maven2/org/apache/xmlbeans/xmlbeans/5.3.0/xmlbeans-5.3.0.jar";
        };
        commons-collections4 = fetchurl {
          hash = "sha256-Hfi5QwtcjtFD14FeQD4z71NxskAKrb6b2giDdi4IRtE=";
          url = "https://repo1.maven.org/maven2/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar";
        };
        commons-math3 = fetchurl {
          hash = "sha256-HlbXsFjSi2Wr0la4RY44hbZ0wdWI+kPNfRy7nH7yswg=";
          url = "https://repo1.maven.org/maven2/org/apache/commons/commons-math3/3.6.1/commons-math3-3.6.1.jar";
        };
        log4j-api = fetchurl {
          hash = "sha256-W0oKDNDnUd7UMcFiRCvb3VMyjR+Lsrrl/Bu+7g9m2A8=";
          url = "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.24.3/log4j-api-2.24.3.jar";
        };
        commons-codec = fetchurl {
          hash = "sha256-ugBfMEzvkqPe3iSjitWsm4r8zw2PdYOdbBM4Y0z39uQ=";
          url = "https://repo1.maven.org/maven2/commons-codec/commons-codec/1.18.0/commons-codec-1.18.0.jar";
        };
        commons-io = fetchurl {
          hash = "sha256-88oPjWPEDiOlbVQQHGDV7e4Ta0LYS/uFvHljCTEJz4s=";
          url = "https://repo1.maven.org/maven2/commons-io/commons-io/2.18.0/commons-io-2.18.0.jar";
        };
        SparseBitSet = fetchurl {
          hash = "sha256-92uFrbDAByGuJnt8/eTaf3HTEhzCFgyfwAwMifjFPIo=";
          url = "https://repo1.maven.org/maven2/com/zaxxer/SparseBitSet/1.3/SparseBitSet-1.3.jar";
        };
      in
      old.XLConnect.overrideAttrs (attrs: {
        postPatch = ''
          substituteInPlace R/onLoad.R \
            --replace-fail 'system2("java",' 'system2("${lib.getExe pkgs.jre_headless}",'

          # Misleading startup message, JARs are downloaded at build-time
          substituteInPlace R/onAttach.R \
            --replace-fail 'if(file.exists(file.path(libname, pkgname, ".fail"))){' 'if(FALSE){'
        '';

        preConfigure = ''
          cp ${poi-ooxml-full} inst/java/poi-ooxml-full-5.4.1.jar
          cp ${poi-ooxml} inst/java/poi-ooxml-5.4.1.jar
          cp ${poi} inst/java/poi-5.4.1.jar
          cp ${commons-compress} inst/java/commons-compress-1.27.1.jar
          cp ${commons-lang3} inst/java/commons-lang3-3.16.0.jar
          cp ${xmlbeans} inst/java/xmlbeans-5.3.0.jar
          cp ${commons-collections4} inst/java/commons-collections4-4.4.jar
          cp ${commons-math3} inst/java/commons-math3-3.6.1.jar
          cp ${log4j-api} inst/java/log4j-api-2.24.3.jar
          cp ${commons-codec} inst/java/commons-codec-1.18.0.jar
          cp ${commons-io} inst/java/commons-io-2.18.0.jar
          cp ${SparseBitSet} inst/java/SparseBitSet-1.3.jar
        '';
      });

    acs = old.acs.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    alcyon = old.alcyon.overrideAttrs (attrs: {
      configureFlags = [
        "--enable-force-openmp"
      ];
    });

    arcgisgeocode = old.arcgisgeocode.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    arcgisplaces = old.arcgisplaces.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    arcgisutils = old.arcgisutils.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    arcpbf = old.arcpbf.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    # it can happen that the major version of arrow-cpp is ahead of the
    # rPackages.arrow that would be built from CRAN sources; therefore, to avoid
    # build failures and manual updates of the hash, we use the R source at
    # the GitHub release state of libarrow (arrow-cpp) in Nixpkgs. This may
    # not exactly represent the CRAN sources, but because patching of the
    # CRAN R package is mostly done to meet special CRAN build requirements,
    # this is a straightforward approach. Example where patching was necessary
    # -> arrow 14.0.0.2 on CRAN; was lagging behind libarrow release:
    #   https://github.com/apache/arrow/issues/39698 )
    arrow = old.arrow.overrideAttrs (attrs: {
      src = pkgs.arrow-cpp.src;

      postPatch = ''
        patchShebangs configure
      '';

      buildInputs = attrs.buildInputs ++ [
        pkgs.arrow-cpp
      ];

      name = "r-arrow-${pkgs.arrow-cpp.version}";
      prePatch = "cd r";
    });

    astgrepr = old.astgrepr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    awdb = old.awdb.overrideAttrs (attrs: {
      postPatch = ''
        patchShebangs configure
      '';
    });

    b32 = old.b32.overrideAttrs (_: {
      preConfigure = "patchShebangs configure";
    });

    b64 = old.b64.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs =
        with pkgs;
        [
          cargo
          rustc
        ]
        ++ attrs.nativeBuildInputs;
    });

    bigPLSR = old.bigPLSR.overrideAttrs (_: {
      preConfigure = "patchShebangs configure";
    });

    cartogramR = old.cartogramR.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    caugi = old.caugi.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    ciflyr = old.ciflyr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    cisPath = old.cisPath.overrideAttrs (attrs: {
      hardeningDisable = [ "format" ];
    });

    clarabel = old.clarabel.overrideAttrs (attrs: {
      postPatch = ''
        patchShebangs configure
      '';
    });

    clustermq = old.clustermq.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    cn_farms = old.cn_farms.overrideAttrs (attrs: {
      postPatch = ''
        # https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2025/01/08#n2025-01-08
        substituteInPlace "src/sparse_farms.c" \
        --replace-fail "Calloc" "R_Calloc" \
        --replace-fail "Free" "R_Free"
      '';
    });

    covidsymptom = old.covidsymptom.overrideAttrs (attrs: {
      preConfigure = "rm R/covidsymptomdata.R";
    });

    cubature = old.cubature.overrideAttrs (attrs: {
      enableParallelBuilding = false;
    });

    curl = old.curl.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    data_table = old.data_table.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -fopenmp";
      };

      patchPhase = "patchShebangs configure";
    });

    datefixR = old.datefixR.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    dbarts = old.dbarts.override { platforms = lib.platforms.x86_64 ++ lib.platforms.x86; };

    devEMF = old.devEMF.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_LINK = "-L${pkgs.libxft.out}/lib -lXft";
        NIX_LDFLAGS = "-lX11";
      };
    });

    enderecobr = old.enderecobr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.cargo
        pkgs.rustc
      ];
    });

    exifr = old.exifr.overrideAttrs (attrs: {
      postPatch = ''
        for f in .onLoad .onAttach ; do
          substituteInPlace R/load_hook.R \
            --replace-fail \
            "$f <- function(libname, pkgname) {" \
            "$f <- function(libname, pkgname) {
                 options(
                     exifr.perlpath = \"${lib.getBin pkgs.perl}/bin/perl\",
                     exifr.exiftoolcommand = \"${lib.getBin pkgs.exiftool}/bin/exiftool\"
                 )"
        done
      '';
    });

    fcl = old.fcl.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    findpython = old.findpython.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "R/find_python_cmd.r" \
          --replace-fail 'python_cmds[which(python_cmds != "")]' \
          'python_cmds <- c(python_cmds, file.path("${lib.getBin pkgs.python3}", "bin", "python3"))
           python_cmds[which(python_cmds != "")]'
      '';
    });

    fio = old.fio.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    fixest = old.fixest.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    float = old.float.overrideAttrs (attrs: {
      enableParallelBuilding = false;
    });

    flowClust = old.flowClust.override { platforms = lib.platforms.x86_64 ++ lib.platforms.x86; };

    gadjid = old.gadjid.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    gdtools = old.gdtools.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_LDFLAGS = "-lfontconfig -lfreetype";
      };

      preConfigure = ''
        patchShebangs configure
      '';
    });

    genoCN = old.genoCN.overrideAttrs (attrs: {
      postPatch = ''
        # https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2025/01/08#n2025-01-08
        substituteInPlace "src/xCNV.c" \
        --replace-fail "Calloc" "R_Calloc" \
        --replace-fail "Free" "R_Free"
      '';
    });

    geojsonio = old.geojsonio.overrideAttrs (attrs: {
      buildInputs = [ cacert ] ++ attrs.buildInputs;
    });

    geomorph = old.geomorph.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        RGL_USE_NULL = "true";
      };
    });

    gifski = old.gifski.overrideAttrs (attrs: {
      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.rustPlatform.cargoSetupHook
        pkgs.cargo
        pkgs.rustc
      ];

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        src = attrs.src;
        hash = "sha256-yz6M3qDQPfT0HJHyK2wgzgl5sBh7EmdJ5zW8SJkk+wY=";
        sourceRoot = "gifski/src/myrustlib";
      };

      cargoRoot = "src/myrustlib";
    });

    gmailr = old.gmailr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    gmapR = old.gmapR.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # Avoid incompatible pointer type error
        NIX_CFLAGS_COMPILE =
          attrs.env.NIX_CFLAGS_COMPILE
          + " -Wno-implicit-function-declaration -Wno-incompatible-pointer-types";
      };
    });

    gpuMagic = old.gpuMagic.overrideAttrs (_: {
      hardeningDisable = [ "format" ];
    });

    h2o = old.h2o.overrideAttrs (attrs: {
      preConfigure = ''
        # prevent download of jar file during install and postpone to first use
        sed -i '/downloadJar()/d' R/zzz.R

        # during runtime the package directory is not writable as it's in the
        # nix store, so store the jar in the user's cache directory instead
        substituteInPlace R/connection.R --replace-fail \
          'dest_file <- file.path(dest_folder, "h2o.jar")' \
          'dest_file <- file.path("~/.cache/", "h2o.jar")'
      '';
    });

    h3o = old.h3o.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    harbinger = old.harbinger.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        LC_ALL = "en_US.UTF-8";
      };
    });

    hdf5r = old.hdf5r.overrideAttrs (attrs: {
      buildInputs = attrs.buildInputs ++ [ new.Rhdf5lib.hdf5 ];
    });

    heck = old.heck.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    httpuv = old.httpuv.overrideAttrs (_: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    httr2 = old.httr2.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    ijtiff = old.ijtiff.overrideAttrs (_: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    immunotation =
      let
        MHC41alleleList = fetchurl {
          hash = "sha256-CRZ+0uHzcq5zK5eONucAChXIXO8tnq5sSEAS80Z7jhg=";
          url = "https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/allele.list";
        };

        MHCII40alleleList = fetchurl {
          hash = "sha256-K4Ic2NUs3P4IkvOODwZ0c4Yh8caex5Ih0uO5jXRHp40=";
          url = "https://services.healthtech.dtu.dk/services/NetMHCIIpan-4.0/alleles_name.list";
        };

        # List of valid countries, regions and ethnic groups
        # The original page is changing a bit every day, but the relevant
        # content does not. Use archive.org to get a stable snapshot.
        # It can be updated from time to time, or when the package becomes
        # deficient. This may be difficult to know.
        # Update the snapshot date, and add id_ after it, as described here:
        # https://web.archive.org/web/20130806040521/http://faq.web.archive.org/page-without-wayback-code/
        validGeographics = fetchurl {
          hash = "sha256-m7Wkmh/cPxeqn94LwoznIh+fcFXskmSGErUYj6kTqak=";
          url = "https://web.archive.org/web/20240418194005id_/http://www.allelefrequencies.net/hla6006a.asp";
        };
      in
      old.immunotation.overrideAttrs (attrs: {
        patches = [ ./patches/immunotation.patch ];

        postPatch = ''
          substituteInPlace "R/external_resources_input.R" --replace-fail \
            "nix-NetMHCpan-4.1-allele-list" ${MHC41alleleList}

          substituteInPlace "R/external_resources_input.R" --replace-fail \
            "nix-NETMHCIIpan-4.0-alleles-name-list" ${MHCII40alleleList}

          substituteInPlace "R/AFND_interface.R" --replace-fail \
            "nix-valid-geographics" ${validGeographics}
        '';
      });

    instantiate = old.instantiate.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    ironseed = old.ironseed.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    iscream = old.iscream.overrideAttrs (attrs: {
      # https://huishenlab.github.io/iscream/articles/htslib.html
      # Rhtslib (in LinkingTo) is not needed if we provide a proper htslib
      propagatedBuildInputs =
        builtins.filter (el: el != pkgs.rPackages.Rhtslib) attrs.propagatedBuildInputs
        ++ [ pkgs.htslib ];
    });

    jqr = old.jqr.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    keyring = old.keyring.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    libdeflate = old.libdeflate.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    libgeos = old.libgeos.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    littler = old.littler.overrideAttrs (
      attrs: with pkgs; {
        buildInputs = [
          pcre
          xz
          zlib
          bzip2
          icu
          which
          zstd.dev
        ]
        ++ attrs.buildInputs;

        postInstall = ''
          install -d $out/bin $out/share/man/man1
          ln -s ../library/littler/bin/r $out/bin/r
          ln -s ../library/littler/bin/r $out/bin/lr
          ln -s ../../../library/littler/man-page/r.1 $out/share/man/man1
          # these won't run without special provisions, so better remove them
          rm -r $out/library/littler/script-tests
        '';
      }
    );

    lpsymphony = old.lpsymphony.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace configure \
          --replace-fail '--libs SYMPHONY' '--libs symphony' \
          --replace-fail '--cflags SYMPHONY' '--cflags symphony'
        patchShebangs configure
      '';
    });

    luajr = old.luajr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
      hardeningDisable = [ "format" ];
    });

    lwgeom = old.lwgeom.overrideAttrs (attrs: {
      configureFlags = [
        "--with-proj-lib=${pkgs.lib.getLib pkgs.proj}/lib"
      ];
    });

    magick = old.magick.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    metahdep = old.metahdep.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # Avoid incompatible pointer type error
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -Wno-int-conversion";
      };
    });

    mongolite = old.mongolite.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKGCONFIG_CFLAGS = "-I${pkgs.openssl.dev}/include -I${pkgs.cyrus_sasl.dev}/include -I${pkgs.zlib.dev}/include";
        PKGCONFIG_LIBS = "-Wl,-rpath,${lib.getLib pkgs.openssl}/lib -L${lib.getLib pkgs.openssl}/lib -L${pkgs.cyrus_sasl.out}/lib -L${pkgs.zlib.out}/lib -lssl -lcrypto -lsasl2 -lz";
      };

      preConfigure = ''
        patchShebangs configure
      '';
    });

    nanonext = old.nanonext.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_LDFLAGS = "-lnng -lmbedtls -lmbedx509 -lmbedcrypto";
      };
    });

    nanoparquet = old.nanoparquet.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    nearfar =
      let
        angrist = fetchurl {
          hash = "sha256-lb+HMHnRGonc26merFGB0B7Vk1Lk+sIJlay+JtQC8m4=";
          url = "https://raw.githubusercontent.com/joerigdon/nearfar/master/angrist.csv";
        };
      in
      old.nearfar.overrideAttrs (attrs: {
        postPatch = ''
          substituteInPlace "R/nearfar.R" --replace-fail \
           'url("https://raw.githubusercontent.com/joerigdon/nearfar/master/angrist.csv")'  '"${angrist}"'
        '';
      });

    networkscaleup = old.networkscaleup.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        # needed to avoid "log limit exceeded" on Hydra
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -Wno-ignored-attributes";
      };

      # consumes a lot of resources in parallel
      enableParallelBuilding = false;
    });

    ocf = old.ocf.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    odbc = old.odbc.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    oligo = old.oligo.overrideAttrs (_: {
      hardeningDisable = [ "format" ];
    });

    opencv =
      let
        opencvGtk = pkgs.opencv.override (old: {
          enableGtk2 = true;
        });
      in
      old.opencv.overrideAttrs (attrs: {
        buildInputs = attrs.buildInputs ++ [ opencvGtk ];
      });

    openssl = old.openssl.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKGCONFIG_CFLAGS = "-I${pkgs.openssl.dev}/include";
        PKGCONFIG_LIBS = "-Wl,-rpath,${lib.getLib pkgs.openssl}/lib -L${lib.getLib pkgs.openssl}/lib -lssl -lcrypto";
      };

      preConfigure = ''
        patchShebangs configure
      '';
    });

    orbweaver = old.orbweaver.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.cargo
        pkgs.rustc
      ];
    });

    otelsdk = old.otelsdk.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    pak = old.pak.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
        patchShebangs src/library/curl/configure
        patchShebangs src/library/keyring/configure
        patchShebangs src/library/pkgdepends/configure
        patchShebangs src/library/ps/configure
      '';
    });

    pathfindR = old.pathfindR.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "R/zzz.R" \
          --replace-fail "    check_java_version()" "    Sys.setenv(JAVA_HOME = \"${lib.getBin pkgs.jre_minimal}\"); check_java_version()"
        substituteInPlace "R/active_snw_search.R" \
          --replace-fail "system(paste0(\"java" "system(paste0(\"${lib.getBin pkgs.jre_minimal}/bin/java"
      '';
    });

    pbdZMQ = old.pbdZMQ.overrideAttrs (attrs: {
      postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
        for file in R/*.{r,r.in}; do
            sed -i 's#system("which \(\w\+\)"[^)]*)#"${pkgs.cctools}/bin/\1"#g' $file
        done
      '';
    });

    pingr = old.pingr.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    pkgdepends = old.pkgdepends.overrideAttrs (attrs: {
      postPatch = ''
        patchShebangs configure
      '';
    });

    protolite = old.protolite.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    prqlr = old.prqlr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    ps = old.ps.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    purrr = old.purrr.overrideAttrs (attrs: {
      patchPhase = "patchShebangs configure";
    });

    quarto = old.quarto.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "R/quarto.R" \
          --replace-fail "Sys.getenv(\"QUARTO_PATH\", unset = NA_character_)" "Sys.getenv(\"QUARTO_PATH\", unset = '${lib.getBin pkgs.quarto}/bin/quarto')"
      '';

      propagatedBuildInputs = attrs.propagatedBuildInputs ++ [ pkgs.quarto ];
    });

    rGADEM = old.rGADEM.overrideAttrs (attrs: {
      hardeningDisable = [ "format" ];
    });

    rJava = old.rJava.overrideAttrs (attrs: {
      preConfigure = ''
        export JAVA_CPPFLAGS=-I${pkgs.jdk}/include/
        export JAVA_HOME=${pkgs.jdk}
        substituteInPlace R/zzz.R.in \
          --replace-fail ".onLoad <- function(libname, pkgname) {" \
            ".onLoad <- function(libname, pkgname) {
             Sys.setenv(\"JAVA_HOME\" = Sys.getenv(\"JAVA_HOME\", unset = \"${pkgs.jdk}\"))"
      '';
    });

    ramr = old.ramr.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    rawrr = old.rawrr.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace "R/zzz.R" "R/dotNetAssembly.R" --replace-warn \
          "Sys.which('mono')" "'${lib.getBin pkgs.mono}/bin/mono'"

        substituteInPlace "R/dotNetAssembly.R" --replace-warn \
          "Sys.which(\"xbuild\")" "\"${lib.getBin pkgs.mono}/bin/xbuild\""

        substituteInPlace "R/dotNetAssembly.R" --replace-warn \
          "cmd <- ifelse(Sys.which(\"msbuild\") != \"\", \"msbuild\", \"xbuild\")" \
          "cmd <- \"${lib.getBin pkgs.mono}/bin/xbuild\""

        substituteInPlace "R/rawrr.R" --replace-warn \
          "Sys.which(\"mono\")" "\"${lib.getBin pkgs.mono}/bin/mono\""
      '';
    });

    rbm25 = old.rbm25.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    redatamx = old.redatamx.overrideAttrs (attrs: {
      preConfigure =
        let
          redatam-core = pkgs.fetchzip {
            hash = "sha256-CagDpv7v5fj/NgaC5fmYc5UuKuBVlT3gauH2ItVnIIY=";
            url = "https://redatam-core.s3.us-west-2.amazonaws.com/core-dev/linux/redatamx-core-linux-20241222.zip";
          };
        in
        ''
          mkdir -p ./inst/redengine/
          cp ${redatam-core}/lib/libredengine-1.0.0-rc2.so ./inst/redengine/libredengine-1.0.0-rc2.so
        '';
    });

    redland = old.redland.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKGCONFIG_CFLAGS = "-I${pkgs.redland}/include -I${pkgs.librdf_raptor2}/include/raptor2 -I${pkgs.librdf_rasqal}/include/rasqal";
        PKGCONFIG_LIBS = "-L${pkgs.redland}/lib -L${pkgs.librdf_raptor2}/lib -L${pkgs.librdf_rasqal}/lib -lrdf -lraptor2 -lrasqal";
      };
    });

    # Append cargo path to path variable
    # This will provide cargo in case it's not set by the user
    rextendr = old.rextendr.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace R/zzz.R --replace-fail \
          ".onLoad <- function(...) {" \
          '.onLoad <- function(...) {
           Sys.setenv(PATH = paste0(Sys.getenv("PATH"), ":${lib.getBin pkgs.cargo}/bin"))'
      '';
    });

    rgl = old.rgl.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        RGL_USE_NULL = "true";
      };
    });

    rgoslin = old.rgoslin.overrideAttrs (attrs: {
      enableParallelBuilding = false;
    });

    rhdf5 = old.rhdf5.overrideAttrs (attrs: {
      patches = [ ./patches/rhdf5.patch ];
      env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
    });

    rhdf5filters = old.rhdf5filters.overrideAttrs (attrs: {
      patches = [ ./patches/rhdf5filters.patch ];
    });

    rlang = old.rlang.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    rmarkdown = old.rmarkdown.overrideAttrs (_: {
      preConfigure = ''
        substituteInPlace R/pandoc.R \
          --replace-fail '"~/opt/pandoc"' '"~/opt/pandoc", "${pkgs.pandoc}/bin"'
      '';
    });

    roxigraph = old.roxigraph.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      env = (attrs.env or { }) // {
        LIBCLANG_PATH = "${lib.getLib pkgs.libclang}/lib";
      };
    });

    rpanel = old.rpanel.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        TCLLIBPATH = "${pkgs.tclPackages.bwidget}/lib/bwidget${pkgs.tclPackages.bwidget.version}";
      };

      preConfigure = ''
        export TCLLIBPATH="${pkgs.tclPackages.bwidget}/lib/bwidget${pkgs.tclPackages.bwidget.version}"
      '';
    });

    rpf = old.rpf.overrideAttrs (attrs: {
      patchPhase = "patchShebangs configure";
    });

    rrd = old.rrd.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    rsgeo = old.rsgeo.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
      nativeBuildInputs = [ pkgs.cargo ] ++ attrs.nativeBuildInputs;
    });

    rshift = old.rshift.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    rstan = old.rstan.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION";
      };
    });

    rtiktoken = old.rtiktoken.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.cargo
        pkgs.rustc
      ];
    });

    rvisidata = old.rvisidata.overrideAttrs (attrs: {
      postPatch = ''
        substituteInPlace R/main.r --replace-fail \
          "system(\"vd" "system(\"${lib.getBin pkgs.visidata}/bin/vd"
        substituteInPlace R/tmux.r --replace-fail \
          "return(\"vd\")" "return(\"${lib.getBin pkgs.visidata}/bin/vd\")"
      '';
    });

    rzmq = old.rzmq.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    s2 = old.s2.overrideAttrs (attrs: {
      preConfigure = ''
        substituteInPlace "configure" \
          --replace-fail "absl_s2" "absl_flags absl_check"
      '';
    });

    sf = old.sf.overrideAttrs (attrs: {
      configureFlags = [
        "--with-proj-lib=${pkgs.lib.getLib pkgs.proj}/lib"
      ];
    });

    slfm = old.slfm.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKG_LIBS = "-L${pkgs.blas}/lib -lblas -L${pkgs.lapack}/lib -llapack";
      };
    });

    socratadata = old.socratadata.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    sodium = old.sodium.overrideAttrs (
      attrs: with pkgs; {
        nativeBuildInputs = [ pkg-config ] ++ attrs.nativeBuildInputs;
        buildInputs = [ libsodium.dev ] ++ attrs.buildInputs;

        preConfigure = ''
          patchShebangs configure
        '';
      }
    );

    sparklyr = old.sparklyr.overrideAttrs (attrs: {
      # Pyspark's spark is full featured and better maintained than pkgs.spark
      preConfigure = ''
        if grep "onLoad" R/zzz.R; then
          echo "onLoad is already present, patch needs to be updated!"
          exit 1
        fi

        cat >> R/zzz.R <<EOF
        .onLoad <- function(...) {
          Sys.setenv("SPARK_HOME" = Sys.getenv("SPARK_HOME", unset = "${pkgs.python3Packages.pyspark}/${pkgs.python3Packages.python.sitePackages}/pyspark"))
          Sys.setenv("JAVA_HOME" = Sys.getenv("JAVA_HOME", unset = "${pkgs.jdk}"))
        }
        EOF
      '';
    });

    surtvep = old.surtvep.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    symengine = old.symengine.overrideAttrs (_: {
      preConfigure = ''
        rm configure
        cat > src/Makevars << EOF
        PKG_LIBS=-lsymengine
        all: $(SHLIB)
        EOF
      '';
    });

    systemfonts = old.systemfonts.overrideAttrs (attrs: {
      preConfigure = "patchShebangs configure";
    });

    tergo = old.tergo.overrideAttrs (attrs: {
      patchPhase = "patchShebangs configure";
    });

    terra = old.terra.overrideAttrs (attrs: {
      configureFlags = [
        "--with-proj-lib=${pkgs.lib.getLib pkgs.proj}/lib"
      ];
    });

    tesseract = old.tesseract.overrideAttrs (_: {
      preConfigure = ''
        substituteInPlace configure \
          --replace-fail 'PKG_CONFIG_NAME="tesseract"' 'PKG_CONFIG_NAME="tesseract lept"'
      '';
    });

    textshaping = old.textshaping.overrideAttrs (attrs: {
      env.NIX_LDFLAGS = "-lfribidi -lharfbuzz";
    });

    timeless = old.timeless.overrideAttrs (attrs: {
      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.rustPlatform.cargoSetupHook
        pkgs.cargo
      ];

      preConfigure = "patchShebangs configure";

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        src = attrs.src;
        hash = "sha256-5TV7iCzaaFwROfJNO6pvSUbJBzV+wZlU5+ZK4AMT6X0=";
        sourceRoot = "timeless/src/rust";
      };

      cargoRoot = "src/rust";
    });

    tok = old.tok.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    tomledit = old.tomledit.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    torch = old.torch.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    trajeR = old.trajeR.overrideAttrs (attrs: {
      patches = [ ./patches/trajeR.patch ];
    });

    trigger = old.trigger.overrideAttrs (attrs: {
      postPatch = ''
        # https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2025/01/08#n2025-01-08
        substituteInPlace "src/trigger.c" \
        --replace-fail "Calloc" "R_Calloc" \
        --replace-fail "Free" "R_Free"
      '';
    });

    universalmotif = old.universalmotif.overrideAttrs (attrs: {
      patches = [ ./patches/universalmotif.patch ];
    });

    unsum = old.unsum.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    vapour = old.vapour.overrideAttrs (attrs: {
      configureFlags = [
        "--with-proj-lib=${pkgs.lib.getLib pkgs.proj}/lib"
      ];
    });

    vegan3d = old.vegan3d.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        RGL_USE_NULL = "true";
      };
    });

    waysign = old.waysign.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    webfakes = old.webfakes.overrideAttrs (_: {
      postPatch = "patchShebangs configure";
    });

    websocket = old.websocket.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        PKGCONFIG_CFLAGS = "-I${pkgs.openssl.dev}/include";
        PKGCONFIG_LIBS = "-Wl,-rpath,${lib.getLib pkgs.openssl}/lib -L${lib.getLib pkgs.openssl}/lib -lssl -lcrypto";
      };
    });

    x13binary = old.x13binary.overrideAttrs (attrs: {
      preConfigure = ''
        patchShebangs configure
      '';
    });

    xactonomial = old.xactonomial.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    xml2 = old.xml2.overrideAttrs (attrs: {
      preConfigure = ''
        export LIBXML_INCDIR=${pkgs.libxml2.dev}/include/libxml2
        patchShebangs configure
      '';
    });

    xslt = old.xslt.overrideAttrs (attrs: {
      env = (attrs.env or { }) // {
        NIX_CFLAGS_COMPILE = attrs.env.NIX_CFLAGS_COMPILE + " -fpermissive";
      };
    });

    yaml12 = old.yaml12.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs = attrs.nativeBuildInputs ++ [
        pkgs.cargo
        pkgs.rustc
      ];
    });

    ymd = old.ymd.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";
    });

    zoomerjoin = old.zoomerjoin.overrideAttrs (attrs: {
      postPatch = "patchShebangs configure";

      nativeBuildInputs = [
        pkgs.cargo
        pkgs.rustc
      ]
      ++ attrs.nativeBuildInputs;
    });
  };
in
self
