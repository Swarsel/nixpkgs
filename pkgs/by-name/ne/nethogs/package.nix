{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nethogs";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "raboof";
    repo = "nethogs";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ojbsCoJ8fOaHgm1tWyM59siTDYmCllXOUNqNQJwRhws=";
  };

  buildInputs = [
    ncurses
    libpcap
  ];

  makeFlags = [
    "VERSION=${finalAttrs.version}"
    "nethogs"
  ];

  installFlags = [
    "PREFIX=$(out)"
    "sbin=$(out)/bin"
  ];

  meta = {
    description = "Small 'net top' tool, grouping bandwidth by process";

    longDescription = ''
      NetHogs is a small 'net top' tool. Instead of breaking the traffic down
      per protocol or per subnet, like most tools do, it groups bandwidth by
      process. NetHogs does not rely on a special kernel module to be loaded.
      If there's suddenly a lot of network traffic, you can fire up NetHogs
      and immediately see which PID is causing this. This makes it easy to
      identify programs that have gone wild and are suddenly taking up your
      bandwidth.
    '';

    homepage = "https://github.com/raboof/nethogs#readme";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.linux;
    mainProgram = "nethogs";
  };
})
