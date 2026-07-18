{
  lib,
  fetchurl,
  asciidoctor,
  buildGoModule,
  ruby,
  which,
}:

buildGoModule (finalAttrs: {
  pname = "reposurgeon";
  version = "5.3";

  src = fetchurl {
    url = "http://www.catb.org/~esr/reposurgeon/reposurgeon-${finalAttrs.version}.tar.xz";
    hash = "sha256-XEPpZyBlTfLGtFQSCHND8OrIPB6ml8HDdg0DSvnmWh8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "./repocutter -q docgen >cuttercommands.inc" 'echo "/* skipped */" >cuttercommands.inc' \
      --replace-fail "./repotool docgen >toolcommands.inc" 'echo "/* skipped */" >toolcommands.inc'
  '';

  nativeBuildInputs = [
    asciidoctor
    ruby
    which
  ];

  vendorHash = "sha256-4bNhAWkO84imCaBzjBxNCOzG2A/z4lhqvu51wF2GVUo=";

  postBuild = ''
    patchShebangs .
    make all HTMLFILES=
  '';

  postInstall = ''
    make install prefix=$out HTMLFILES=
  '';

  subPackages = [ "." ];

  meta = {
    description = "Tool for editing version-control repository history";
    homepage = "http://www.catb.org/esr/reposurgeon/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dfoxfranke ];
    platforms = lib.platforms.all;
  };
})
