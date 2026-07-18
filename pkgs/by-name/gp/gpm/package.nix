{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  fetchpatch,
  flex,
  libtool,
  ncurses,
  pkgsStatic,
  texinfo,
  withNcurses ? false,
}:

stdenv.mkDerivation {
  pname = "gpm";
  version = "unstable-2020-06-17";

  src = fetchFromGitHub {
    owner = "telmich";
    repo = "gpm";
    rev = "e82d1a653ca94aa4ed12441424da6ce780b1e530";
    sha256 = "0ndn6dwc87slvyqp2cnbb02a6hkjwb6zjhs6viysykv06hq7ihy6";
  };

  outputs = [
    "out"
    "dev"
    "info"
    "man"
  ];

  patches = [
    (fetchpatch {
      sha256 = "1f74h12iph4z1dldbxk9imcq11805c3ai2xhbsqvx8jpjrcfp19q";
      # pull request telmich/gpm#42
      url = "https://github.com/kaction/gpm/commit/217b4fe4c9b62298a4e9a54c1f07e3b52b013a09.patch";
    })

    # Pull fix pending upstream inclusion to fix parallel installation:
    #   https://github.com/telmich/gpm/pull/43
    (fetchpatch {
      name = "parallel-install.patch";
      sha256 = "0g1jhz9bjw7vqjv922xkhs8xkjxdqh11nj38jj3c8nv5lcil76nx";
      url = "https://github.com/telmich/gpm/commit/a88fb82a7afe96e872bb31c554e9ad5888f5a451.patch";
    })
  ];

  postPatch = ''
    substituteInPlace src/prog/gpm-root.y --replace __sigemptyset sigemptyset
  '';

  nativeBuildInputs = [
    automake
    autoconf
    libtool
    flex
    bison
    texinfo
  ];

  buildInputs = [ ncurses ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (lib.withFeature withNcurses "curses")
    # The code won't compile in c23 mode.
    # https://gcc.gnu.org/gcc-15/porting_to.html#c23-fn-decls-without-parameters
    "CFLAGS=-std=gnu17"
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  # Provide libgpm.so for compatibility
  postInstall = ''
    if test -e "$out/lib/libgpm.so.2"; then
      ln -sv "$out/lib/libgpm.so.2" "$out/lib/libgpm.so"
    else
      rm -f "$out/lib/libgpm.so.2"
    fi
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];
  passthru.tests.static = pkgsStatic.gpm;

  meta = {
    description = "Daemon that provides mouse support on the Linux console";
    homepage = "https://www.nico.schottelius.org/software/gpm/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.cygwin;
  };
}
