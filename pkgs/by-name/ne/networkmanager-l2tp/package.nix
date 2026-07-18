{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  gtk3,
  gtk4,
  libnma,
  libnma-gtk4,
  libsecret,
  networkmanager,
  nss,
  openssl,
  pkg-config,
  ppp,
  replaceVars,
  strongswan,
  xl2tpd,
  withGnome ? true,
}:

stdenv.mkDerivation rec {
  pname = "NetworkManager-l2tp";
  version = "1.52.0";

  src = fetchFromGitHub {
    owner = "nm-l2tp";
    repo = "NetworkManager-l2tp";
    rev = version;
    hash = "sha256-5EIG/5fexhrcOOQE+31+TJKMtINGVL+EI32m9tEhYVo=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit strongswan xl2tpd;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    glib # for gdbus-codegen
    pkg-config
  ]
  ++ lib.optionals withGnome [
    gtk4 # for gtk4-builder-tool
  ];

  buildInputs = [
    networkmanager
    ppp
    openssl
    nss
  ]
  ++ lib.optionals withGnome [
    gtk3
    gtk4
    libsecret
    libnma
    libnma-gtk4
  ];

  configureFlags = [
    "--with-gnome=${lib.boolToYesNo withGnome}"
    "--with-gtk4=${lib.boolToYesNo withGnome}"
    "--localstatedir=/var"
    "--enable-absolute-paths"
  ];

  enableParallelBuilding = true;
  name = "${pname}${lib.optionalString withGnome "-gnome"}-${version}";

  passthru = {
    networkManagerPlugin = "VPN/nm-l2tp-service.name";
  };

  meta = {
    inherit (networkmanager.meta) platforms;
    description = "L2TP plugin for NetworkManager";
    homepage = "https://github.com/nm-l2tp/NetworkManager-l2tp";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      obadz
    ];
  };
}
