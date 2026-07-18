{
  stdenv,
  fetchFromGitHub,
  bpp-core,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (bpp-core) version postPatch;
  pname = "bpp-seq";

  src = fetchFromGitHub {
    owner = "BioPP";
    repo = "bpp-seq";
    rev = "v${finalAttrs.version}";
    sha256 = "1mc09g8jswzsa4wgrfv59jxn15ys3q8s0227p1j838wkphlwn2qk";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ bpp-core ];
  # prevents cmake from exporting incorrect INTERFACE_INCLUDE_DIRECTORIES
  # of form /nix/store/.../nix/store/.../include,
  # probably due to relative vs absolute path issue
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = ''
    substituteInPlace $out/lib/cmake/bpp-seq/bpp-seq-targets.cmake  \
      --replace 'set(_IMPORT_PREFIX' '#set(_IMPORT_PREFIX'
  '';

  meta = bpp-core.meta // {
    homepage = "https://github.com/BioPP/bpp-seq";
    changelog = "https://github.com/BioPP/bpp-seq/blob/master/ChangeLog";
  };
})
