{
  lib,
  stdenv,
  fetchurl,
  expat,
  libmysqlclient,
  pkg-config,
  enableMysql ? true,
  enableXmlpipe2 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sphinxsearch";
  version = "2.2.11";

  src = fetchurl {
    url = "https://sphinxsearch.com/files/sphinx-${finalAttrs.version}-release.tar.gz";
    sha256 = "1aa1mh32y019j8s3sjzn4vwi0xn83dwgl685jnbgh51k16gh6qk6";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    lib.optionals enableMysql [
      libmysqlclient
    ]
    ++ lib.optionals enableXmlpipe2 [
      expat
    ];

  configureFlags = [
    "--program-prefix=sphinxsearch-"
    "--enable-id64"
  ]
  ++ lib.optionals (!enableMysql) [
    "--without-mysql"
  ];

  env.CXXFLAGS = "-std=c++98";
  enableParallelBuilding = true;

  meta = {
    description = "Open source full text search server";
    homepage = "http://sphinxsearch.com";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      ederoyd46
      valodim
    ];

    platforms = lib.platforms.all;
  };
})
