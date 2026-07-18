{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  libdatrie,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libthai";
  version = "0.1.30";

  src = fetchurl {
    url = "https://github.com/tlwg/libthai/releases/download/v${finalAttrs.version}/libthai-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-3bqLU9/lhMMlN2YDAhioiCVIilGn3u8EHQlucVr2S90=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    (lib.getBin libdatrie)
    pkg-config
  ];

  buildInputs = [ libdatrie ];

  postInstall = ''
    installManPage man/man3/*.3
  '';

  meta = {
    description = "Set of Thai language support routines";
    homepage = "https://linux.thai.net/projects/libthai/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ crertel ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libthai" ];
  };
})
