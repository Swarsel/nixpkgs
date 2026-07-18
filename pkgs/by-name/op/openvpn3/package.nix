{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  asio_1_32_0,
  cmake,
  fmt_11,
  gdbuspp,
  git,
  glib,
  gobject-introspection,
  jsoncpp,
  libcap_ng,
  libnl,
  libuuid,
  lz4,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  python3,
  systemd,
  tinyxml-2,
  unzip,
  wrapGAppsHook3,
  enableSystemdResolved ? true,
}:
let
  # Derived from subprojects/fmt.wrap
  libfmt-meson-patch = fetchurl {
    hash = "sha256-ZFvxwzWiRgi0s08W7RC5I3u7ATFIhmj7hkVCAiOeCGw=";
    url = "https://wrapdb.mesonbuild.com/v2/fmt_11.2.0-1/get_patch";
  };
in
stdenv.mkDerivation rec {
  pname = "openvpn3";
  version = "27.1";

  src = fetchFromGitHub {
    owner = "OpenVPN";
    repo = "openvpn3-linux";
    tag = "v${version}";
    hash = "sha256-Egt6lVcvlmxnABw4v0cdROQzVdkA3DgOGGCSgl+QFdM=";
    # `openvpn3-core` is a submodule.
    # TODO: make it into a separate package
    fetchSubmodules = true;
  };

  patches = [
    ./0001-handle-result-from-DcoKeyConfig_ParseFromString.patch
  ];

  postPatch = ''
    echo '#define OPENVPN_VERSION "3.git:unknown:unknown"
    #define PACKAGE_GUIVERSION "v${builtins.replaceStrings [ "_" ] [ ":" ] version}"
    #define PACKAGE_NAME "openvpn3-linux"
    ' > ./src/build-version.h

    patchShebangs \
      ./scripts \
      ./src/python/{openvpn2,openvpn3-as,openvpn3-autoload} \
      ./distro/systemd/openvpn3-systemd \
      ./src/tests/dbus/netcfg-subscription-test \
      ./src/shell/bash-completion/gen-openvpn2-completion.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    git
    unzip

    python3.pkgs.wrapPython
    python3.pkgs.docutils
    python3.pkgs.jinja2
    python3.pkgs.dbus-python
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    # Depends on io_service
    asio_1_32_0
    glib
    jsoncpp
    libcap_ng
    libnl
    libuuid
    lz4
    openssl
    protobuf
    tinyxml-2
    gdbuspp
  ]
  ++ lib.optionals enableSystemdResolved [ systemd.dev ];

  mesonFlags = [
    (lib.mesonOption "selinux" "disabled")
    (lib.mesonOption "selinux_policy" "disabled")
    (lib.mesonOption "bash-completion" "enabled")
    (lib.mesonOption "test_programs" "disabled")
    (lib.mesonOption "unit_tests" "disabled")
    (lib.mesonOption "asio_path" "${asio_1_32_0}")
    (lib.mesonOption "dbus_policy_dir" "${placeholder "out"}/share/dbus-1/system.d")
    (lib.mesonOption "dbus_system_service_dir" "${placeholder "out"}/share/dbus-1/system-services")
    (lib.mesonOption "systemd_system_unit_dir" "${placeholder "out"}/lib/systemd/system")
    (lib.mesonOption "systemd_user_unit_dir" "${placeholder "out"}/lib/systemd/user")
    (lib.mesonOption "create_statedir" "false")
    (lib.mesonOption "sharedstatedir" "/etc")
  ];

  env.NIX_LDFLAGS = "-lpthread";

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonPrograms
    wrapPythonProgramsIn "$out/libexec/openvpn3-linux" "$out ${pythonPath}"
  '';

  dontWrapGApps = true;

  prePatch = ''
    cp -r ${fmt_11.src} subprojects/fmt-11.2.0
    chmod +w -R subprojects/fmt-11.2.0 # Allow patches for subprojects to work
    tmp=$(mktemp -d)
    unzip ${libfmt-meson-patch} -d $tmp
    cp -r $tmp/*/* subprojects/fmt-11.2.0
  '';

  pythonPath = python3.withPackages (ps: [
    ps.dbus-python
    ps.pygobject3
    ps.systemd-python
  ]);

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenVPN 3 Linux client";
    homepage = "https://github.com/OpenVPN/openvpn3-linux/";
    changelog = "https://github.com/OpenVPN/openvpn3-linux/releases/tag/v${version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      progrm_jarvis
    ];

    platforms = lib.platforms.linux;
  };
}
