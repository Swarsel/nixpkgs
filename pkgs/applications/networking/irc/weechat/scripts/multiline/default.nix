{
  lib,
  stdenv,
  fetchurl,
  PodParser,
  replaceVars,
}:

stdenv.mkDerivation {
  pname = "multiline";
  version = "0.6.4";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/weechat/scripts/5f073d966e98d54344a91be4f5afc0ec9e2697dc/perl/multiline.pl";
    sha256 = "sha256-TXbU2Q7Tm8iTwOQqrWpqHXuKrjoBFLyUWRsH+TsR9Lo=";
  };

  patches = [
    # The script requires a special Perl environment.
    (replaceVars ./libpath.patch {
      env = PodParser;
    })
  ];

  installPhase = ''
    runHook preInstall

    install -D multiline.pl $out/share/multiline.pl

    runHook postInstall
  '';

  dontUnpack = true;

  prePatch = ''
    cp $src multiline.pl
  '';

  passthru.scripts = [ "multiline.pl" ];

  meta = {
    description = "Multi-line edit box";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
