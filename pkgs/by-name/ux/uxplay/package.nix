{
  lib,
  stdenv,
  fetchFromGitHub,
  avahi,
  avahi-compat,
  cmake,
  gst_all_1,
  libplist,
  nix-update-script,
  openssl,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uxplay";
  version = "1.73.6";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NQqrrTQiWcOhWFrdqniK6FnmOSIVGS4/cRDg5gd3bOE=";
  };

  postPatch = ''
    substituteInPlace lib/CMakeLists.txt \
      --replace "APPLE" "FALSE" \
      --replace ".a" "${stdenv.hostPlatform.extensions.sharedLibrary}"
    sed -i -e '/PKG_CONFIG_EXECUTABLE/d' -e '/PKG_CONFIG_PATH/d' renderers/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    avahi
    avahi-compat
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    libplist
    openssl
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AirPlay Unix mirroring server";
    homepage = "https://github.com/FDH2/UxPlay";
    changelog = "https://github.com/FDH2/UxPlay/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.azuwis ];
    platforms = lib.platforms.unix;
    mainProgram = "uxplay";
  };
})
