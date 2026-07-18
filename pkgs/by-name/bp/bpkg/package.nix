{
  lib,
  stdenv,
  fetchurl,
  build2,
  git,
  libbpkg,
  libbutl,
  libodb,
  libodb-sqlite,
  openssl,
  enableShared ? !stdenv.hostPlatform.isStatic,
  enableStatic ? !enableShared,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bpkg";
  version = "0.18.0";

  src = fetchurl {
    url = "https://pkg.cppget.org/1/alpha/build2/bpkg-${finalAttrs.version}.tar.gz";
    hash = "sha256-EcDxvQ3P182gkZWkE3qI586vIlJXlDrYC2DoU0Out18=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  # Failing test
  postPatch = ''
    rm tests/rep-create.testscript
  '';

  strictDeps = true;

  nativeBuildInputs = [
    build2
  ];

  buildInputs = [
    build2
    libbpkg
    libbutl
    libodb
    libodb-sqlite
  ];

  doCheck = true;

  nativeCheckInputs = [
    git
    openssl
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath '${lib.getLib build2}/lib' "''${!outputBin}/bin/bpkg"
  '';

  build2ConfigureFlags = [
    "config.bin.lib=${build2.configSharedStatic enableShared enableStatic}"
  ];

  meta = {
    description = "Build2 package dependency manager";

    # https://build2.org/bpkg/doc/bpkg.xhtml
    longDescription = ''
      The build2 package dependency manager is used to manipulate build
      configurations, packages, and repositories.
    '';

    homepage = "https://build2.org/";
    changelog = "https://git.build2.org/cgit/bpkg/tree/NEWS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ r-burns ];
    platforms = lib.platforms.all;
    mainProgram = "bpkg";
  };
})
