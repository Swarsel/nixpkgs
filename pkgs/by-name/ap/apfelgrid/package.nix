{
  lib,
  stdenv,
  fetchFromGitHub,
  apfel,
  applgrid,
  autoreconfHook,
  lhapdf,
  root,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apfelgrid";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "nhartland";
    repo = "APFELgrid";
    tag = "v${finalAttrs.version}";
    sha256 = "0l0cyxd00kmb5aggzwsxg83ah0qiwav0shbxkxwrz3dvw78n89jk";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    apfel
    applgrid
    lhapdf
    root
    zlib
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Ultra-fast theory predictions for collider observables";
    homepage = "https://nhartland.github.io/APFELgrid/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "apfelgrid-config";
  };
})
