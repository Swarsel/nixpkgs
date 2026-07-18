{
  stdenv,
  fetchFromGitHub,
  bpp-core,
  bpp-seq,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (bpp-core) version postPatch;
  pname = "bpp-popgen";

  src = fetchFromGitHub {
    owner = "BioPP";
    repo = "bpp-popgen";
    rev = "v${finalAttrs.version}";
    sha256 = "0bz0fhrq3dri6a0hvfc3zlvrns8mrzzlnicw5pyfa812gc1qwfvh";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bpp-core
    bpp-seq
  ];

  # prevents cmake from exporting incorrect INTERFACE_INCLUDE_DIRECTORIES
  # of form /nix/store/.../nix/store/.../include,
  # probably due to relative vs absolute path issue
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = ''
    substituteInPlace $out/lib/cmake/bpp-popgen/bpp-popgen-targets.cmake  \
      --replace 'set(_IMPORT_PREFIX' '#set(_IMPORT_PREFIX'
  '';

  meta = bpp-core.meta // {
    homepage = "https://github.com/BioPP/bpp-popgen";
    changelog = "https://github.com/BioPP/bpp-popgen/blob/master/ChangeLog";
  };
})
