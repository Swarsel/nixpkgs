{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  boost,
  cmake,
  ctestCheckHook,
  flex,
  libedit,
  libpq,
  mariadb-connector-c,
  openssl,
  patchelf,
  protobuf,
  runCommand,
  systemd,
  tzdata,
  zlib,
  nameSuffix ? "",
  # Features
  withChecker ? true,
  withCompat ? false,
  withIcingadb ? true,
  withLivestatus ? false,
  # Databases
  withMysql ? true,
  withNotification ? true,
  withOtel ? true,
  withPerfdata ? true,
  withPostgresql ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icinga2${nameSuffix}";
  version = "2.16.3";

  src = fetchFromGitHub {
    owner = "icinga";
    repo = "icinga2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0gKNHtSc6uaabDHujlUKrcZfx6wz0vDp7Z4YMSem4iY=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    ./etc-icinga2.patch # Makes /etc/icinga2 relative to / instead of the store path
    ./no-systemd-service.patch # Prevent systemd service from being written to /usr
    ./no-var-directories.patch # Prevent /var directories from being created
  ];

  nativeBuildInputs = [
    cmake
    flex
    bison
    patchelf
  ];

  buildInputs = [
    boost
    libedit
    openssl
    systemd
  ]
  ++ lib.optional withOtel protobuf
  ++ lib.optional withPostgresql libpq;

  cmakeFlags =
    let
      mkFeatureFlag = label: value: "-DICINGA2_WITH_${label}=${if value then "ON" else "OFF"}";
    in
    [
      # Paths
      "-DCMAKE_INSTALL_SYSCONFDIR=etc"
      "-DCMAKE_INSTALL_LOCALSTATEDIR=/var"
      "-DCMAKE_INSTALL_FULL_SBINDIR=bin"
      "-DICINGA2_RUNDIR=/run"
      "-DMYSQL_INCLUDE_DIR=${mariadb-connector-c.dev}/include/mariadb"
      "-DMYSQL_LIB=${mariadb-connector-c.out}/lib/mariadb/libmysqlclient.a"
      "-DICINGA2_PLUGINDIR=bin"
      "-DICINGA2_LTO_BUILD=yes"
      # Features
      (mkFeatureFlag "MYSQL" withMysql)
      (mkFeatureFlag "PGSQL" withPostgresql)
      (mkFeatureFlag "CHECKER" withChecker)
      (mkFeatureFlag "COMPAT" withCompat)
      (mkFeatureFlag "LIVESTATUS" withLivestatus)
      (mkFeatureFlag "NOTIFICATION" withNotification)
      (mkFeatureFlag "PERFDATA" withPerfdata)
      (mkFeatureFlag "ICINGADB" withIcingadb)
      (mkFeatureFlag "OPENTELEMETRY" withOtel)
      # Misc.
      "-DICINGA2_USER=icinga2"
      "-DICINGA2_GROUP=icinga2"
      "-DICINGA2_GIT_VERSION_INFO=OFF"
      "-DUSE_SYSTEMD=ON"
    ];

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook # ctestFlags needs this
    tzdata # legacytimeperiod/dst needs this
  ];

  postFixup = ''
    rm -r $out/etc/logrotate.d $out/etc/sysconfig $out/lib/icinga2/prepare-dirs

    # Fix hardcoded paths
    sed -i 's:/usr/bin/::g' $out/etc/icinga2/scripts/*

    # Get rid of sbin
    sed -i 's/sbin/bin/g' $out/lib/icinga2/safe-reload
    rm $out/sbin

    ${lib.optionalString withMysql ''
      # Add dependencies of the MySQL shim to the shared library
      patchelf --add-needed ${zlib.out}/lib/libz.so $(readlink -f $out/lib/icinga2/libmysql_shim.so)

      # Make Icinga find the MySQL shim
      icinga2Bin=$out/lib/icinga2/sbin/icinga2
      patchelf --set-rpath $out/lib/icinga2:$(patchelf --print-rpath $icinga2Bin) $icinga2Bin
    ''}
  '';

  # https://github.com/Icinga/icinga2/issues/10722#issuecomment-4178294982
  ctestFlags = [
    "-LE"
    "network"
  ];

  vim = runCommand "vim-icinga2-${finalAttrs.version}" { pname = "vim-icinga2"; } ''
    mkdir -p $out/share/vim-plugins
    cp -r "${finalAttrs.src}/tools/syntax/vim" $out/share/vim-plugins/icinga2
  '';

  meta = {
    description = "Open source monitoring system";
    homepage = "https://www.icinga.com";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];

    platforms = lib.platforms.linux;
  };
})
