{
  lib,
  stdenv,
  autoreconfHook,
  curl,
  fetchgit,
  gnunet,
  jq,
  libgcrypt,
  libtool,
  makeWrapper,
  nixosTests,
  pkg-config,
  qrencode,
  taler-exchange,
  taler-wallet-core,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-merchant";
  version = "1.3.0";

  src = fetchgit {
    url = "https://git-www.taler.net/merchant.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nrXokwZ0IFXAH3B12/FDAhhyE6JAiiJ59cuWLwLM684=";
    fetchSubmodules = true;
  };

  # Use an absolute path for `templates` and `spa` directories, else a relative
  # path to the `taler-exchange` package is used.
  postPatch = ''
    substituteInPlace src/backend/taler-merchant-httpd.c \
      --replace-fail 'TALER_TEMPLATING_init (TALER_MERCHANT_project_data ())' "TALER_TEMPLATING_init_path (\"merchant\", \"$out/share/taler\")"

    substituteInPlace src/backend/taler-merchant-httpd_spa.c \
      --replace-fail 'TALER_MHD_spa_load (TALER_MERCHANT_project_data (),' "TALER_MHD_spa_load_dir (\"$out/share/taler/merchant/spa/\");" \
      --replace-fail '"spa/");' ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    makeWrapper
    libgcrypt # AM_PATH_LIBGCRYPT
    texinfo # makeinfo
  ];

  buildInputs = taler-exchange.buildInputs ++ [
    qrencode
    taler-exchange
    # for ltdl.h
    libtool
  ];

  propagatedBuildInputs = [ gnunet ];

  configureFlags = [
    "ac_cv_path__libcurl_config=${lib.getDev curl}/bin/curl-config"
  ];

  nativeCheckInputs = [ jq ];

  # NOTE: The executables that need database access fail to detect the
  # postgresql library in `$out/lib/taler`, so we need to wrap them.
  postInstall = ''
    for exec in dbinit httpd webhook wirewatch depositcheck exchangekeyupdate; do
      wrapProgram $out/bin/taler-merchant-$exec \
        --prefix LD_LIBRARY_PATH : "$out/lib/taler"
    done
  '';

  doInstallCheck = true;

  postFixup = ''
    # - taler-merchant-dbinit expects `versioning.sql` under `share/taler/sql`
    # - taler-merchant-httpd expects `share/taler/merchant/templates`
    mkdir -p $out/share/taler/sql
    ln -s $out/share/taler-merchant $out/share/taler/merchant
    ln -s $out/share/taler-merchant/sql $out/share/taler/sql/merchant
  '';

  checkTarget = "check";
  enableParallelBuilding = true;

  postUnpack = ''
    ln -s ${taler-wallet-core}/spa.html $sourceRoot/contrib/
  '';

  # From ./bootstrap
  preAutoreconf = ''
    pushd contrib
    find wallet-core/backoffice/ -type f -printf '  %p \\\n' | sort > Makefile.am.ext
    truncate -s -2 Makefile.am.ext
    cat Makefile.am.in Makefile.am.ext >> Makefile.am
    popd
  '';

  passthru.tests = nixosTests.taler.basic;

  meta = {
    description = "Merchant component for the GNU Taler electronic payment system";

    longDescription = ''
      This is the GNU Taler merchant backend. It provides the logic that should run
      at every GNU Taler merchant.  The GNU Taler merchant is a RESTful backend that
      can be used to setup orders and process payments.  This component allows
      merchants to receive payments without invading the customers' privacy. Of
      course, this applies mostly for digital goods, as the merchant does not need
      to know the customer's physical address.
    '';

    homepage = "https://taler.net/";
    changelog = "https://git-www.taler.net/merchant.git/tree/ChangeLog?h=v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ astro ];
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ ngi ];
  };
})
