{
  lib,
  stdenv,
  fetchFromGitHub,
  groff,
  pcre2,
  perl,
  util-linux,
  vdr,
}:
stdenv.mkDerivation rec {
  pname = "vdr-epgsearch";
  version = "2.4.6";

  src = fetchFromGitHub {
    owner = "vdr-projects";
    repo = "vdr-plugin-epgsearch";
    rev = "v${version}";
    sha256 = "sha256-+csxlLBSIKiYIjgEPj0IUP8wZX9zuOM26cgA99uZ3EA=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    for f in *.sh; do
      patchShebangs "$f"
    done
  '';

  nativeBuildInputs = [
    perl # for pod2man and pos2html
    util-linux
    groff
  ];

  buildInputs = [
    vdr
    pcre2
  ];

  buildFlags = [
    "SENDMAIL="
  ];

  installFlags = [
    "DESTDIR=$(out)"
  ];

  meta = {
    inherit (src.meta) homepage;
    inherit (vdr.meta) platforms;
    description = "Searchtimer and replacement of the VDR program menu";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.ck3d ];
    mainProgram = "createcats";
  };
}
