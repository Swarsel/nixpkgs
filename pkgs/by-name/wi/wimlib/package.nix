{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  pkg-config,
  cabextract ? null,
  cdrkit ? null,
  fuse3 ? null,
  mtools ? null,
  ntfs3g ? null,
  syslinux ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wimlib";
  version = "1.14.5";

  src = fetchurl {
    url = "https://wimlib.net/downloads/wimlib-${finalAttrs.version}.tar.gz";
    hash = "sha256-hCIaOr1bkSKPFfjmBlwzWjNiN7VzgZe3W/QZ7qVhoZQ=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ ntfs3g ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ fuse3 ];

  preBuild = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace programs/mkwinpeimg.in \
      --replace '/usr/lib/syslinux' "${syslinux}/share/syslinux"
  '';

  doCheck = (!stdenv.hostPlatform.isDarwin);

  preCheck = ''
    patchShebangs tests
  '';

  postInstall =
    let
      path = lib.makeBinPath (
        [
          cabextract
          mtools
          ntfs3g
        ]
        ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
          cdrkit
          syslinux
          fuse3
        ]
      );
    in
    ''
      for prog in $out/bin/*; do
        wrapProgram $prog --prefix PATH : $out/bin:${path}
      done
    '';

  enableParallelBuilding = true;

  meta = {
    description = "Library and program to extract, create, and modify WIM files";
    homepage = "https://wimlib.net";

    license = with lib.licenses; [
      gpl3
      lgpl3
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
