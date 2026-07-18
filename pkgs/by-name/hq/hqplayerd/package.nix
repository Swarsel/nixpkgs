{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  alsa-lib,
  autoPatchelfHook,
  cairo,
  callPackage,
  flac,
  gcc14,
  # gssdp,
  # gupnp,
  gupnp-av,
  lame,
  libgmpris,
  libusb-compat-0_1,
  llvmPackages_19,
  mpg123,
  rpmextract,
  wavpack,
}:
let
  rygel-hqplayerd = callPackage ./rygel.nix { };
in
stdenv.mkDerivation rec {
  pname = "hqplayerd";
  version = "5.13.2-39";

  src = fetchurl {
    url = "https://www.signalyst.eu/bins/hqplayerd/fc37/hqplayerd-${version}.fc37.x86_64.rpm";
    hash = "sha256-4wB32xFYpGcBdLqSZFkNXoS7IerPS8f6KIpn13ulqUY=";
  };

  nativeBuildInputs = [
    addDriverRunpath
    autoPatchelfHook
    rpmextract
  ];

  buildInputs = [
    alsa-lib
    cairo
    flac
    gcc14.cc.lib
    rygel-hqplayerd
    # gssdp
    # gupnp
    gupnp-av
    lame
    libgmpris
    libusb-compat-0_1
    llvmPackages_19.openmp
    mpg123
    wavpack
  ];

  installPhase = ''
    runHook preInstall

    # executables
    mkdir -p $out
    cp -rv ./usr/bin $out/bin

    # libs
    mkdir -p $out
    cp -rv ./opt/hqplayerd/lib $out

    # configuration
    mkdir -p $out/etc
    cp -rv ./etc/hqplayer $out/etc/

    # systemd service file
    mkdir -p $out/lib/systemd
    cp -rv ./usr/lib/systemd/system $out/lib/systemd/

    # documentation
    mkdir -p $out/share/doc
    cp -rv ./usr/share/doc/hqplayerd $out/share/doc/

    # misc service support files
    mkdir -p $out/var/lib
    cp -rv ./var/lib/hqplayer $out/var/lib/
    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/lib/systemd/system/hqplayerd.service \
      --replace /usr/bin/hqplayerd $out/bin/hqplayerd \
      --replace "NetworkManager-wait-online.service" ""
  '';

  # NB: addDriverRunpath needs to run _after_ autoPatchelfHook, which runs in
  # postFixup, so we tack it on here.
  doInstallCheck = true;

  installCheckPhase = ''
    addDriverRunpath $out/bin/hqplayerd
    $out/bin/hqplayerd --version
  '';

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    rpmextract $src
  '';

  passthru = {
    rygel = rygel-hqplayerd;
  };

  meta = {
    description = "High-end upsampling multichannel software embedded HD-audio player";
    homepage = "https://www.signalyst.com/custom.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = [ "x86_64-linux" ];
    # libsoup 2.4 and its dependents (specifically gupnp and gssdp) were
    # removed due to being insecure and having many known vulnerabilities. this
    # thus no longer builds. this may be unbroken by updating to hqplayer 6.0,
    # as it ostensibly removes the need for rygel and gupnp at all.
    broken = true;
  };
}
