{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash-completion,
  fetchpatch,
  libutempter,
  makeWrapper,
  ncurses,
  openssh,
  openssl,
  perl,
  pkg-config,
  protobuf,
  zlib,
  # build server binary only when set to false (useful for perlless systems)
  withClient ? true,
  withUtempter ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mosh";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "mobile-shell";
    repo = "mosh";
    rev = "mosh-${finalAttrs.version}";
    hash = "sha256-tlSsHu7JnXO+sorVuWWubNUNdb9X0/pCaiGG5Y0X/g8=";
  };

  patches = [
    ./ssh_path.patch
    ./mosh-client_path.patch
    # Fix build with bash-completion 2.10
    ./bash_completion_datadir.patch

    # Fixes build with protobuf3 23.x
    (fetchpatch {
      hash = "sha256-CouLHWSsyfcgK3k7CvTK3FP/xjdb1pfsSXYYQj3NmCQ=";
      url = "https://github.com/mobile-shell/mosh/commit/eee1a8cf413051c2a9104e8158e699028ff56b26.patch";
    })
  ];

  postPatch = ''
    substituteInPlace scripts/mosh.pl \
      --subst-var-by ssh "${openssh}/bin/ssh" \
      --subst-var-by mosh-client "$out/bin/mosh-client"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    makeWrapper
    protobuf
    perl
  ];

  buildInputs = [
    protobuf
    ncurses
    zlib
    openssl
    bash-completion
  ]
  ++ lib.optionals withClient [
    perl
  ]
  ++ lib.optional withUtempter libutempter;

  configureFlags = [ "--enable-completion" ] ++ lib.optional withUtempter "--with-utempter";

  postInstall =
    if withClient then
      ''
        wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB
      ''
    else
      ''
        rm $out/bin/mosh
        rm $out/bin/mosh-client
        rm -r $out/share/{man,bash-completion}
      '';

  enableParallelBuilding = true;

  meta = {
    description = "Mobile shell (ssh replacement)";

    longDescription = ''
      Remote terminal application that allows roaming, supports intermittent
      connectivity, and provides intelligent local echo and line editing of
      user keystrokes.

      Mosh is a replacement for SSH. It's more robust and responsive,
      especially over Wi-Fi, cellular, and long-distance links.
    '';

    homepage = "https://mosh.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ skeuchel ];
    platforms = lib.platforms.unix;
  };
})
