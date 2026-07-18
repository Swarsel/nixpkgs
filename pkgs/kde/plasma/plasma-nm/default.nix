{
  lib,
  kirigami-addons,
  mkKdeDerivation,
  mobile-broadband-provider-info,
  openconnect,
  openvpn,
  pkg-config,
  qtkeychain,
  qtwebengine,
  replaceVars,
  strongswan,
}:
mkKdeDerivation {
  pname = "plasma-nm";

  patches = [
    (replaceVars ./hardcode-paths.patch {
      ipsec = lib.getExe' strongswan "ipsec";
      openvpn = lib.getExe openvpn;
    })
  ];

  extraBuildInputs = [
    qtkeychain
    qtwebengine
    mobile-broadband-provider-info
    openconnect
  ];

  extraNativeBuildInputs = [ pkg-config ];
  extraPropagatedBuildInputs = [ kirigami-addons ];
}
