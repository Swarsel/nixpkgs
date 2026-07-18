{
  lib,
  stdenv,
  fetchurl,
  cpio,
  e2fsprogs,
  glibc,
  ocaml-ng,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "supermin";
  version = "5.3.5";

  src = fetchurl {
    url = "https://download.libguestfs.org/supermin/${lib.versions.majorMinor finalAttrs.version}-development/supermin-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-0oLIHccG7+pGZIGhOfmwso0sHqagofV912GmvBG5nOI=";
  };

  postPatch = ''
    patchShebangs src/bin2c.pl
  '';

  nativeBuildInputs = [
    cpio
    e2fsprogs
    perl
    pkg-config
  ]
  ++ (with ocaml-ng.ocamlPackages_4_14; [
    findlib
    ocaml
  ]);

  buildInputs = lib.optionals stdenv.hostPlatform.isGnu [
    glibc
    glibc.static
  ];

  meta = {
    description = "Tool for creating and building supermin appliances";
    homepage = "https://libguestfs.org/supermin.1.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.linux;
    mainProgram = "supermin";
  };
})
