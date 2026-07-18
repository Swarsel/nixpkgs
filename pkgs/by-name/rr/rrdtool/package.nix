{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  fetchpatch,
  gettext,
  groff,
  libxml2,
  pango,
  perl,
  pkg-config,
  tcl,
}:

perl.pkgs.toPerlModule (
  stdenv.mkDerivation (finalAttrs: {
    pname = "rrdtool";
    version = "1.9.0";

    src = fetchFromGitHub {
      owner = "oetiker";
      repo = "rrdtool-1.x";
      rev = "v${finalAttrs.version}";
      hash = "sha256-CPbSu1mosNlfj2nqiNVH14a5C5njkfvJM8ix3X3aP8E=";
    };

    # Fix darwin build
    patches = lib.optional stdenv.hostPlatform.isDarwin (fetchpatch {
      hash = "sha256-aP0rmDlILn6VC8Tg7HpRXbxL9+KD/PRTbXnbQ7HgPEg=";
      url = "https://github.com/oetiker/rrdtool-1.x/pull/1262.patch";
    });

    nativeBuildInputs = [
      pkg-config
      autoreconfHook
    ];

    buildInputs = [
      gettext
      perl
      libxml2
      pango
      cairo
      groff
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      tcl
    ];

    postInstall = ''
      # for munin and rrdtool support
      mkdir -p $out/${perl.libPrefix}
      mv $out/lib/perl/5* $out/${perl.libPrefix}
    '';

    meta = {
      description = "High performance logging in Round Robin Databases";
      homepage = "https://oss.oetiker.ch/rrdtool/";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [ pSub ];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  })
)
