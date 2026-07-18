{
  lib,
  fetchFromGitHub,
  avahi,
  buildGoModule,
  libusb1,
  pkg-config,
  ronn,
}:
buildGoModule (finalAttrs: {
  pname = "ipp-usb";
  version = "0.9.34";

  src = fetchFromGitHub {
    owner = "openprinting";
    repo = "ipp-usb";
    rev = finalAttrs.version;
    sha256 = "sha256-4xZf8Q1MfQcB13vHRdb8dQyZWrwnJzubdi+zln1lRc8=";
  };

  postPatch = ''
    # rebuild with patched paths
    rm ipp-usb.8
    substituteInPlace Makefile \
      --replace-fail "install: all" "install: man" \
      --replace-fail "/usr/" "/" \
      --replace-fail "install -s" "install" # Nix already strips binaries in $out/sbin, this also fixes cross
    substituteInPlace systemd-udev/ipp-usb.service --replace-fail "/sbin" "$out/bin"
    for i in paths.go ipp-usb.8.md; do
      substituteInPlace $i --replace-fail "/usr" "$out"
      substituteInPlace $i --replace-fail "/var/ipp-usb" "/var/lib/ipp-usb"
    done
  '';

  nativeBuildInputs = [
    pkg-config
    ronn
  ];

  buildInputs = [
    libusb1
    avahi
  ];

  vendorHash = null;

  postInstall = ''
    # to accommodate the makefile
    cp $out/bin/ipp-usb .
    make install DESTDIR=$out
  '';

  doInstallCheck = true;

  meta = {
    description = "Daemon to use the IPP everywhere protocol with USB printers";
    homepage = "https://github.com/OpenPrinting/ipp-usb";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.symphorien ];
    platforms = lib.platforms.linux;
    mainProgram = "ipp-usb";
  };
})
