{
  lib,
  stdenv,
  fetchurl,
  netsurf-buildsystem,
  pkg-config,
  publicsuffix-list,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnspsl";
  version = "0.1.7";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libnspsl-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-NoTOwy9VXa7UMZk+C/bL2TdPbJCERiN+CJ8LYdaUrIA=";
  };

  postPatch = ''
    rm public_suffix_list.dat
    ln -s ${publicsuffix-list}/share/publicsuffix/public_suffix_list.dat public_suffix_list.dat
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "NetSurf Public Suffix List - Handling library";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
  };
})
