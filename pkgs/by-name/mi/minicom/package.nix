{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libiconv,
  lrzsz,
  makeWrapper,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minicom";
  version = "2.10";

  src = fetchFromGitLab {
    owner = "minicom-team";
    repo = "minicom";
    rev = finalAttrs.version;
    sha256 = "sha256-wC6VlMRwuhV1zQ26wNx7gijuze8E2CvnzpqOSIPzq2s=";
    domain = "salsa.debian.org";
  };

  patches = [ ./xminicom_terminal_paths.patch ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    ncurses
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--enable-lock-dir=/var/lock"
  ];

  preConfigure = ''
    # Have `configure' assume that the lock directory exists.
    substituteInPlace configure \
      --replace 'test -d $UUCPLOCK' true
  '';

  postInstall = ''
    for f in $out/bin/*minicom ; do
      wrapProgram $f \
        --prefix PATH : ${lib.makeBinPath [ lrzsz ]}:$out/bin
    done
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Modem control and terminal emulation program";

    longDescription = ''
      Minicom is a menu driven communications program. It emulates ANSI
      and VT102 terminals. It has a dialing directory and auto zmodem
      download.
    '';

    homepage = "https://salsa.debian.org/minicom-team/minicom";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
  };
})
