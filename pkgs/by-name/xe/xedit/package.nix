{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxaw,
  libxmu,
  libxt,
  pkg-config,
  util-macros,
}:

stdenv.mkDerivation rec {
  pname = "xedit";
  version = "1.2.5";

  src = fetchFromGitLab {
    owner = "xorg/app";
    repo = "xedit";
    rev = "${pname}-${version}";
    sha256 = "sha256-+nWtoqm+5ie2U5nFJRioftMkxJFNtws09kTelmWhqgA=";
    domain = "gitlab.freedesktop.org";
  };

  # ./lisp/mathimp.c:493:10: error: implicitly declaring library function 'finite' with type 'int (double)'
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    for i in $(find . -type f -name "*.c"); do
      substituteInPlace $i --replace "finite" "isfinite"
    done
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ];

  buildInputs = [
    libx11
    libxaw
    libxmu
    libxt
  ];

  configureFlags = [
    "--with-lispdir=$out/share/X11/xedit/lisp"
    "--with-appdefaultdir=$out/share/X11/app-defaults"
  ];

  meta = {
    description = "Simple graphical text editor using Athena Widgets (Xaw)";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xedit";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.unix;
    mainProgram = "xedit";
    # never built on aarch64-darwin, x86_64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin;
  };
}
