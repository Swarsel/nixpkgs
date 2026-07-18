{
  stdenv,
  fetchFromGitHub,
  bpp-core,
  bpp-seq,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (bpp-core) version postPatch;
  pname = "bpp-phyl";

  src = fetchFromGitHub {
    owner = "BioPP";
    repo = "bpp-phyl";
    rev = "v${finalAttrs.version}";
    sha256 = "192zks6wyk903n06c2lbsscdhkjnfwms8p7jblsmk3lvjhdipb20";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bpp-core
    bpp-seq
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = ''
    substituteInPlace $out/lib/cmake/bpp-phyl/bpp-phyl-targets.cmake  \
      --replace 'set(_IMPORT_PREFIX' '#set(_IMPORT_PREFIX'
  '';

  meta = bpp-core.meta // {
    homepage = "https://github.com/BioPP/bpp-phyl";
    changelog = "https://github.com/BioPP/bpp-phyl/blob/master/ChangeLog";
  };
})
