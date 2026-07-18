{
  lib,
  stdenv,
  fetchFromGitHub,
  asterisk,
  binutils-unwrapped,
  patchelf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "asterisk-module-sccp";
  version = "4.3.5";

  src = fetchFromGitHub {
    owner = "chan-sccp";
    repo = "chan-sccp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lonsh7rx3C17LU5pZpZuFxlki0iotDt+FivggFJbldU=";
  };

  nativeBuildInputs = [ patchelf ];
  configureFlags = [ "--with-asterisk=${asterisk}" ];

  postInstall = ''
    mkdir -p "$out"
    cp -r /build/dest/${asterisk}/* "$out"
  '';

  postFixup = ''
    p="$out/lib/asterisk/modules/chan_sccp.so"
    patchelf --set-rpath "$p:${lib.makeLibraryPath [ binutils-unwrapped ]}" "$p"
  '';

  installFlags = [
    "DESTDIR=/build/dest"
    "DATAROOTDIR=/build/dest"
  ];

  meta = {
    description = "Replacement for the SCCP channel driver in Asterisk";
    homepage = "https://github.com/chan-sccp/chan-sccp";
    license = lib.licenses.gpl1Only;
    maintainers = with lib.maintainers; [ das_j ];
    # https://github.com/chan-sccp/chan-sccp/issues/609
    broken = lib.versionAtLeast (lib.getVersion asterisk) "21";
  };
})
