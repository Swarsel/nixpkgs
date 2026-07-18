{
  lib,
  stdenv,
  fetchurl,
  curl,
  espeak,
  file,
  gtk3,
  gtkdatabox,
  intltool,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "klavaro";
  version = "3.14";

  src = fetchurl {
    url = "mirror://sourceforge/klavaro/klavaro-${finalAttrs.version}.tar.bz2";
    hash = "sha256-hxh+SdMBxRDmlkCYzbYSEmvwMNKodf15nq3K0+rlbas=";
  };

  postPatch = ''
    substituteInPlace src/tutor.c --replace '"espeak ' '"${espeak}/bin/espeak '
  '';

  nativeBuildInputs = [
    intltool
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    curl
    gtk3
    gtkdatabox
  ];

  # Fixes /usr/bin/file: No such file or directory
  preConfigure = ''
    substituteInPlace configure \
      --replace "/usr/bin/file" "${file}/bin/file"
  '';

  postInstall = ''
    wrapProgram $out/bin/klavaro \
      --prefix LD_LIBRARY_PATH : $out/lib
  '';

  # remove forbidden references to $TMPDIR
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    for f in "$out"/bin/*; do
      if isELF "$f"; then
        patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$f"
      fi
    done
  '';

  meta = {
    description = "Free touch typing tutor program";
    homepage = "http://klavaro.sourceforge.net/";
    changelog = "https://sourceforge.net/p/klavaro/code/HEAD/tree/trunk/ChangeLog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mimame
      davidak
    ];

    platforms = lib.platforms.linux;
    mainProgram = "klavaro";
  };
})
