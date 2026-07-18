{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoreconfHook,
  fetchpatch,
  help2man,
  libftdi1,
  libice,
  libsm,
  libusb-compat-0_1,
  libx11,
  libxslt,
  linuxHeaders,
  pkg-config,
  python3,
  systemd,
}:

let
  pythonEnv = python3.pythonOnBuildForHost.withPackages (
    p: with p; [
      pyyaml
      setuptools
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lirc";
  version = "0.10.2";

  src = fetchurl {
    url = "mirror://sourceforge/lirc/lirc-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-PUTsgnSIHPJi8WCAVkHwgn/8wgreDYXn5vO5Dg09Iio=";
  };

  outputs = [
    "out"
    "man"
    "doc"
    "dev"
    # This is the output referenced by dependent packages most of the time.
    # $out on the other hand contains files used by direct users of lirc -
    # systemd units, binaries, shell scripts & lirc python package. Since
    # Nixpkgs' stdenv puts by default python libraries in $lib, this causes a
    # cyclic reference between $out and $lib. We solve this by moving the
    # Python library to $out in postFixup below. Since the Python library is
    # also strongly related to the direct usage of lirc (and not only linking
    # to the libraries of it), this makes sense anyway.
    "lib"
  ];

  patches = [
    # Fix installation of Python bindings
    (fetchpatch {
      sha256 = "088a39x8c1qd81qwvbiqd6crb2lk777wmrs8rdh1ga06lglyvbly";
      url = "https://sourceforge.net/p/lirc/tickets/339/attachment/0001-Fix-Python-bindings.patch";
    })

    # Add a workaround for linux-headers-5.18 until upstream adapts:
    #   https://sourceforge.net/p/lirc/git/merge-requests/45/
    ./linux-headers-5.18.patch

    # remove check for `Ubuntu` in /proc/version which will override
    # --with-systemdsystemunitdir
    # https://sourceforge.net/p/lirc/tickets/385/
    ./ubuntu.diff

    # fix overriding PYTHONPATH
    ./pythonpath.patch
  ];

  postPatch = ''
    patchShebangs .

    # Pull fix for new pyyaml pending upstream inclusion
    #   https://sourceforge.net/p/lirc/git/merge-requests/39/
    substituteInPlace python-pkg/lirc/database.py \
      --replace-fail 'yaml.load(' 'yaml.safe_load('

    substituteInPlace systemd/*.service \
      --replace-fail "ExecStart=/usr/" "ExecStart=''${!outputBin}/"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    help2man
    libxslt
    pythonEnv
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    systemd
    libusb-compat-0_1
    libftdi1
    libice
    libsm
    libx11
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-systemdsystemunitdir=$(out)/lib/systemd/system"
    "--enable-uinput" # explicit activation because build env has no uinput
    "--enable-devinput" # explicit activation because build env has no /dev/input
    "--with-lockdir=/run/lirc/lock" # /run/lock is not writable for 'lirc' user
    "PYTHON=${pythonEnv.interpreter}"
  ];

  env.DEVINPUT_HEADER = "${linuxHeaders}/include/linux/input-event-codes.h";

  preConfigure = ''
    export PKGCONFIG="$PKG_CONFIG"
  '';

  postFixup = ''
    moveToOutput "${python3.sitePackages}" "$out"
    # $out/bin/lirc-setup is symlinked to $lib/''${python3.sitePackages}, so it
    # has to be fixed due to the above.
    rm $out/bin/lirc-setup
    ln -s $out/${python3.sitePackages}/lirc-setup/lirc-setup $out/bin/lirc-setup
  '';

  # Upstream ships broken symlinks in docs
  dontCheckForBrokenSymlinks = true;

  installFlags = [
    "sysconfdir=$out/etc"
    "localstatedir=$TMPDIR"
  ];

  meta = {
    description = "Allows to receive and send infrared signals";
    homepage = "https://www.lirc.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
})
