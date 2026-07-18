{
  lib,
  accounts-qt,
  kaccounts-integration,
  libpq,
  mariadb,
  mkKdeDerivation,
  qttools,
  shared-mime-info,
  sqlite,
  xz,
  backend ? "mysql",
}:

assert lib.assertOneOf "backend" backend [
  "mysql"
  "postgres"
  "sqlite"
];

mkKdeDerivation {
  pname = "akonadi";

  patches = [
    # Always regenerate MySQL config, as the store paths don't have accurate timestamps
    ./ignore-mysql-config-timestamp.patch
  ];

  # Hardcoded as a QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
  ''
  + lib.optionalString (backend == "mysql") ''
    echo "${mariadb}" > $out/nix-support/depends
  ''
  + lib.optionalString (backend == "postgres") ''
    echo "${libpq}" > $out/nix-support/depends
  '';

  extraBuildInputs = [
    kaccounts-integration
    accounts-qt
    xz
  ]
  ++ lib.optionals (backend == "mysql") [ mariadb ]
  ++ lib.optionals (backend == "postgres") [ libpq ]
  ++ lib.optionals (backend == "sqlite") [ sqlite ];

  extraCmakeFlags = [
    "-DDATABASE_BACKEND=${lib.toUpper backend}"
  ]
  ++ lib.optionals (backend == "mysql") [
    "-DMYSQLD_SCRIPTS_PATH=${lib.getBin mariadb}/bin"
  ]
  ++ lib.optionals (backend == "postgres") [
    "-DPOSTGRES_PATH=${lib.getBin libpq}/bin"
  ];

  extraNativeBuildInputs = [
    qttools
    shared-mime-info
  ];
}
