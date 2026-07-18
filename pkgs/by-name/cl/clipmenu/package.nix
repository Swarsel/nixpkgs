{
  lib,
  stdenv,
  fetchFromGitHub,
  clipnotify,
  coreutils,
  gawk,
  makeWrapper,
  util-linux,
  xdotool,
  xsel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "clipmenu";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "cdown";
    repo = "clipmenu";
    rev = finalAttrs.version;
    sha256 = "sha256-nvctEwyho6kl4+NXi76jT2kG7nchmI2a7mgxlgjXA5A=";
  };

  postPatch = ''
    sed -i init/clipmenud.service \
      -e "s,/usr/bin,$out/bin,"
  '';

  nativeBuildInputs = [
    makeWrapper
    xsel
    clipnotify
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postFixup = ''
    sed -i "$out/bin/clipctl" -e 's,clipmenud\$,\.clipmenud-wrapped\$,'

    wrapProgram "$out/bin/clipmenu" \
      --prefix PATH : "${lib.makeBinPath [ xsel ]}"

    wrapProgram "$out/bin/clipmenud" \
      --set PATH "${
        lib.makeBinPath [
          clipnotify
          coreutils
          gawk
          util-linux
          xdotool
          xsel
        ]
      }"
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Clipboard management using dmenu";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ jb55 ];
  };
})
