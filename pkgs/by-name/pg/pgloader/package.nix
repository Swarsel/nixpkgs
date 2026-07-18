{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cacert,
  curl,
  freetds,
  git,
  installShellFiles,
  libzip,
  makeWrapper,
  openssl,
  sbcl_2_4_6,
  sphinx,
  sqlite,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pgloader";
  version = "3.6.9";

  nativeBuildInputs = [
    git
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    sbcl_2_4_6
    cacert
    sqlite
    sphinx
    freetds
    libzip
    curl
    openssl
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    sqlite
    libzip
    curl
    git
    openssl
    freetds
  ];

  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR

    pushd pgloader-bundle-${finalAttrs.version}
    make pgloader
    popd

    pushd source/docs
    make man
    popd
  '';

  installPhase = ''
    install -Dm755 pgloader-bundle-${finalAttrs.version}/bin/pgloader "$out/bin/pgloader"
    wrapProgram $out/bin/pgloader --prefix LD_LIBRARY_PATH : "${finalAttrs.env.LD_LIBRARY_PATH}"
    mkdir -p $out/bin $out/man/man1
    installManPage source/docs/_build/man/*.1
  '';

  dontStrip = true;
  enableParallelBuilding = false;
  sourceRoot = ".";

  srcs = [
    (fetchurl {
      sha256 = "sha256-pdCcRmoJnrfVnkhbT0WqLrRbCtOEmRgGRsXK+3uByeA=";
      url = "https://github.com/dimitri/pgloader/releases/download/v3.6.9/pgloader-bundle-3.6.9.tgz";
    })
    # needed because bundle does not contain docs / man pages
    (fetchFromGitHub {
      hash = "sha256-lqvfWayaJbZ9xx4CgFfY1g0TKwFEd5IWf+RLLXQddw4=";
      owner = "dimitri";
      repo = "pgloader";
      rev = "v${finalAttrs.version}";
    })
  ];

  meta = {
    description = "Loads data into PostgreSQL and allows you to implement Continuous Migration from your current database to PostgreSQL";
    homepage = "https://pgloader.io/";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ mguentner ];
    platforms = lib.platforms.all;
    mainProgram = "pgloader";
  };
})
