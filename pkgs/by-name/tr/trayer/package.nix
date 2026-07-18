{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  gdk-pixbuf,
  gtk2,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "trayer";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "sargon";
    repo = "trayer-srg";
    rev = "${pname}-${version}";
    sha256 = "1mvhwaqa9bng9wh3jg3b7y8gl7nprbydmhg963xg0r076jyzv0cg";
  };

  patches = [
    # Adding missing arg in function decleration
    (fetchpatch {
      hash = "sha256-LighVaBDePheBO+dWG6JHhm/Y6sxdtvTrBar8VrPRH4=";
      name = "fix_function_dec.patch";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/x11-misc/trayer-srg/files/trayer-srg-1.1.8-fix-define.patch?id=94ae89d1b044c24138d5c8903df68e9654a5462f";
    })
  ];

  postPatch = ''
    patchShebangs configure
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gdk-pixbuf
    gtk2
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Lightweight GTK2-based systray for UNIX desktop";
    homepage = "https://github.com/sargon/trayer-srg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "trayer";
  };
}
