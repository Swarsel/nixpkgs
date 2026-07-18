{
  lib,
  stdenv,
  fetchFromGitHub,
  bashNonInteractive,
  buildNpmPackage,
  cjson,
  cmake,
  dbus,
  jsoncpp,
  nodejs,
  pkg-config,
  protobuf,
  systemdLibs,
}:
let
  pname = "openthread-border-router";
  version = "2026.06.0";

  src = fetchFromGitHub {
    owner = "openthread";
    repo = "ot-br-posix";
    tag = "v${version}";
    hash = "sha256-7si62h1nXnAzEmloThCcOeY3VhfSIFV+7kWKgJywcvk=";
    fetchSubmodules = true;
  };

  frontendModules = buildNpmPackage {
    inherit version;
    pname = "${pname}-frontend";
    src = "${src}/src/web/web-service/frontend";
    npmDepsHash = "sha256-7UVfPICyIbHEClpr3p7eDR46OUzS8mVf6P7phnDpVLk=";
    dontNpmBuild = true;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  patches = [
    # Patch the firewall script so we can run it within the systemd start script
    ./firewall-script.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    nodejs
  ];

  buildInputs = [
    systemdLibs
    protobuf
    jsoncpp
    dbus
    cjson
    (lib.getBin bashNonInteractive)
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")

    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeBool "INSTALL_SYSTEMD_UNIT" false)
    (lib.cmakeBool "Boost_USE_STATIC_LIBS" false)
    (lib.cmakeBool "OTBR_REST" true)

    # OpenThread's built-in mDNS publisher (upstream default). No Avahi daemon needed.
    (lib.cmakeFeature "OTBR_MDNS" "openthread")

    (lib.cmakeBool "OTBR_WEB" true)
    (lib.cmakeBool "OTBR_NAT64" true)
    (lib.cmakeBool "OTBR_BACKBONE_ROUTER" true)
    (lib.cmakeBool "OTBR_BORDER_ROUTING" true)
    (lib.cmakeBool "OTBR_DBUS" true)
    (lib.cmakeBool "OTBR_TREL" true)

    (lib.cmakeFeature "OTBR_VERSION" version)
    # otbr-agent aborts on startup with "Vendor name must be set." unless a vendor
    # and product name are baked in at build time.
    (lib.cmakeFeature "OTBR_VENDOR_NAME" "NixOS")
    (lib.cmakeFeature "OTBR_PRODUCT_NAME" "OpenThread Border Router")
    # OTBR_MDNS=openthread turns on the OT-core advertising and discovery proxies by default.
    # The discovery proxy gives us the DNS-SD server OTBR_DNS_UPSTREAM_QUERY needs.
    (lib.cmakeBool "OTBR_DNS_UPSTREAM_QUERY" true)

    (lib.cmakeBool "OT_CHANNEL_MANAGER" true)
    (lib.cmakeBool "OT_CHANNEL_MONITOR" true)

    # Required by protobuf
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
  ];

  # Adding npmConfigHook and manually passing fetchNpmDeps was resulting in ENOTCACHED errors
  postConfigure = ''
    ln -sf ${frontendModules}/lib/node_modules/otbr-web/node_modules ./src/web/web-service/frontend/
  '';

  postInstall = ''
    install -Dm555 -t $out/bin ../script/otbr-firewall
  '';

  __structuredAttrs = true;

  meta = {
    description = "Thread border router for POSIX-based platforms";
    homepage = "https://github.com/openthread/ot-br-posix";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      jamiemagee
      leonm1
      mrene
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ot-ctl";
  };
}
