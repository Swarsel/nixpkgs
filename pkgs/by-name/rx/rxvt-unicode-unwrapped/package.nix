{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  fontconfig,
  freetype,
  gdk-pixbuf,
  libptytty,
  libx11,
  libxext,
  libxft,
  libxrender,
  libxt,
  makeDesktopItem,
  ncurses,
  nixosTests,
  perl,
  pkg-config,
  emojiSupport ? false,
  gdkPixbufSupport ? true,
  perlSupport ? true,
  unicode3Support ? true,
}:

let
  pname = "rxvt-unicode";
  version = "9.31";
  description = "Clone of the well-known terminal emulator rxvt";

  desktopItem = makeDesktopItem {
    categories = [
      "System"
      "TerminalEmulator"
    ];

    comment = description;
    desktopName = "URxvt";
    exec = "urxvt";
    genericName = pname;
    icon = "utilities-terminal";
    name = pname;
  };

  fetchPatchFromAUR =
    {
      name,
      package,
      rev,
      sha256,
    }:
    fetchpatch rec {
      inherit name sha256;
      extraPrefix = "";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=${package}&id=${rev}";
    };
in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-${version}.tar.bz2";
    sha256 = "qqE/y8FJ/g8/OR+TMnlYD3Spb9MS1u0GuP8DwtRmcug=";
  };

  outputs = [
    "out"
    "terminfo"
  ];

  patches =
    (
      if emojiSupport then
        [
          (fetchPatchFromAUR {
            name = "enable-wide-glyphs.patch";
            package = "rxvt-unicode-truecolor-wide-glyphs";
            rev = "69701a09c2c206233952b84bc966407f6774f1dc";
            sha256 = "0jfcj0ahky4dxdfrhqvh1v83mblhf5nak56dk1vq3bhyifdg7ffq";
          })
          (fetchPatchFromAUR {
            name = "improve-font-rendering.patch";
            package = "rxvt-unicode-truecolor-wide-glyphs";
            rev = "69701a09c2c206233952b84bc966407f6774f1dc";
            sha256 = "1jj5ai2182nq912279adihi4zph1w4dvbdqa1pwacy4na6y0fz9y";
          })
        ]
      else
        [
          ./patches/9.06-font-width.patch
        ]
    )
    ++ [
      ./patches/256-color-resources.patch
      (fetchPatchFromAUR {
        name = "7-bit-queries.patch";
        package = "rxvt-unicode-truecolor-wide-glyphs";
        rev = "61ed186890a2bf37585e4704a095be61e6504ac6";
        sha256 = "1xpv6g3bhxq5gp40k3rp8yjp4xrw7dr2g9sfkdmj0gi3rr0myx46";
      })
    ]
    ++ lib.optional (perlSupport && lib.versionAtLeast perl.version "5.38") (fetchpatch {
      excludes = [ "Changes" ];
      name = "perl538-locale-c.patch";
      sha256 = "sha256-JVqzYi3tcWIN2j5JByZSztImKqbbbB3lnfAwUXrumHM=";
      url = "https://github.com/exg/rxvt-unicode/commit/16634bc8dd5fc4af62faf899687dfa8f27768d15.patch";
    })
    ++ lib.optional stdenv.hostPlatform.isDarwin ./patches/makefile-phony.patch;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxt
    libxft
    ncurses # required to build the terminfo file
    fontconfig
    freetype
    libxrender
    libptytty
  ]
  ++ lib.optionals perlSupport [
    perl
    libxext
  ]
  ++ lib.optional gdkPixbufSupport gdk-pixbuf;

  configureFlags = [
    "--with-terminfo=${placeholder "terminfo"}/share/terminfo"
    "--enable-256-color"
    (lib.enableFeature perlSupport "perl")
    (lib.enableFeature unicode3Support "unicode3")
  ]
  ++ lib.optional emojiSupport "--enable-wide-glyphs";

  env = {
    CFLAGS = toString [
      "-I${freetype.dev}/include/freetype2"
    ];

    LDFLAGS = toString [
      "-lfontconfig"
      "-lXrender"
      "-lpthread"
    ];
  };

  preConfigure = ''
    # without this the terminfo won't be compiled by tic, see man tic
    mkdir -p $terminfo/share/terminfo
    export TERMINFO=$terminfo/share/terminfo
  ''
  + lib.optionalString perlSupport ''
    # make urxvt find its perl file lib/perl5/site_perl
    # is added to PERL5LIB automatically
    mkdir -p $out/$(dirname ${perl.libPrefix})
    ln -s $out/lib/urxvt $out/${perl.libPrefix}
  '';

  postInstall = ''
    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
    cp -r ${desktopItem}/share/applications/ $out/share/
  '';

  name = "${pname}-unwrapped-${version}";
  passthru.tests.test = nixosTests.terminal-emulators.urxvt;

  meta = {
    inherit description;
    homepage = "http://software.schmorp.de/pkg/rxvt-unicode.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.unix;
    mainProgram = "urxvt";
    downloadPage = "http://dist.schmorp.de/rxvt-unicode/Attic/";
  };
}
