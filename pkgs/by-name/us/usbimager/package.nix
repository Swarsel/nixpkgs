{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  gtk3,
  libx11,
  pkg-config,
  udisks,
  wrapGAppsHook3,
  withLibui ? true,
  withUdisks ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "usbimager";
  version = "1.0.10";

  src = fetchFromGitLab {
    owner = "bztsrc";
    repo = "usbimager";
    rev = finalAttrs.version;
    hash = "sha256-HTFopc2xrhp0XYubQtOwMKWTQ+3JSKAyL4mMyQ82kAs=";
  };

  # libui is bundled with the source of usbimager as a compiled static library
  postPatch = ''
    sed -i \
      -e 's|install -m 2755 -g disk|install |g' \
      -e 's|-I/usr/include/gio-unix-2.0|-I${glib.dev}/include/gio-unix-2.0|g' \
      -e 's|install -m 2755 -g $(GRP)|install |g' Makefile
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs =
    lib.optionals withUdisks [
      udisks
      glib
    ]
    ++ lib.optional (!withLibui) libx11
    ++ lib.optional withLibui gtk3;

  makeFlags = [
    "PREFIX=$(out)"
  ]
  ++ lib.optional withLibui "USE_LIBUI=yes"
  ++ lib.optional withUdisks "USE_UDISKS2=yes";

  postInstall = ''
    substituteInPlace $out/share/applications/usbimager.desktop \
      --replace-fail "Exec=/usr/bin/usbimager" "Exec=usbimager"
  '';

  dontConfigure = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Very minimal GUI app that can write compressed disk images to USB drives";
    homepage = "https://gitlab.com/bztsrc/usbimager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vdot0x23 ];
    # windows and darwin could work, but untested
    # feel free add them if you have a machine to test
    platforms = with lib.platforms; linux;
    mainProgram = "usbimager";
    # never built on aarch64-linux since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  };
})
