{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf-archive,
  autoreconfHook,
  bison,
  callPackage,
  # test
  dejagnu,
  flex,
  libxcrypt,
  ncurses,
  # passthru
  nix-update-script,
  nixosTests,
  perl,
  pkg-config,
  python3Packages,
  swig,
  which,
  withPerl ?
    stdenv.hostPlatform == stdenv.buildPlatform && lib.meta.availableOn stdenv.hostPlatform perl,
  withPython ?
    # static can't load python libraries
    !stdenv.hostPlatform.isStatic
    && lib.meta.availableOn stdenv.hostPlatform python3Packages.python
    # m4 python include script fails if cpu bit depth is different across machines
    && stdenv.hostPlatform.parsed.cpu.bits == stdenv.buildPlatform.parsed.cpu.bits,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libapparmor";
  version = "5.0.0";

  src = fetchFromGitLab {
    owner = "apparmor";
    repo = "apparmor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-seEREIc83alEPyZGD/GY48hjpqiw3QENnqYsdjHOGgs=";
  };

  postPatch = ''
    substituteInPlace swig/perl/Makefile.am \
      --replace-fail install_vendor install_site
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    bison
    flex
    pkg-config
    swig
    ncurses
    which
    dejagnu
    perl # podchecker
  ]
  ++ lib.optionals withPython [
    python3Packages.setuptools
  ];

  buildInputs = [
    libxcrypt
  ]
  ++ (lib.optional withPerl perl)
  ++ (lib.optional withPython python3Packages.python);

  # https://gitlab.com/apparmor/apparmor/issues/1
  configureFlags = [
    (lib.withFeature withPerl "perl")
    (lib.withFeature withPython "python")
  ];

  doCheck = withPerl && withPython;

  nativeCheckInputs = [
    python3Packages.pythonImportsCheckHook
  ];

  checkInputs = [ dejagnu ];
  # required to build apparmor-parser
  dontDisableStatic = true;

  pythonImportsCheck = [
    "LibAppArmor"
  ];

  sourceRoot = "${finalAttrs.src.name}/libraries/libapparmor";

  passthru = {
    apparmorRulesFromClosure = callPackage ./apparmorRulesFromClosure.nix { };
    tests.nixos = nixosTests.apparmor;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Mandatory access control system - core library";
    homepage = "https://apparmor.net/";

    license = with lib.licenses; [
      gpl2Only
      lgpl21Only
    ];

    maintainers = lib.teams.apparmor.members;
    platforms = lib.platforms.linux;
  };
})
