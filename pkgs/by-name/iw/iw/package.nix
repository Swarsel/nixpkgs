{
  lib,
  stdenv,
  fetchurl,
  libnl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iw";
  version = "6.17";

  src = fetchurl {
    url = "https://www.kernel.org/pub/software/network/iw/iw-${finalAttrs.version}.tar.xz";
    hash = "sha256-fRguSYKJqzmyV9pngNVi5BU3cQf1A1juW1W4z+QLHjM=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libnl ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Tool to use nl80211";

    longDescription = ''
      iw is a new nl80211 based CLI configuration utility for wireless devices.
      It supports all new drivers that have been added to the kernel recently.
      The old tool iwconfig, which uses Wireless Extensions interface, is
      deprecated and it's strongly recommended to switch to iw and nl80211.
    '';

    homepage = "https://wireless.wiki.kernel.org/en/users/Documentation/iw";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.linux;
    mainProgram = "iw";
  };
})
