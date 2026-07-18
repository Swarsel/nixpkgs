{
  lib,
  stdenv,
  fetchurl,
  ladspa-header,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cmt";
  version = "1.18";

  src = fetchurl {
    url = "https://www.ladspa.org/download/cmt_${finalAttrs.version}.tgz";
    sha256 = "sha256-qC+GNt4fSto4ahmaAXqc13Wkm0nnFrEejdP3I8k99so=";
  };

  buildInputs = [ ladspa-header ];

  preBuild = ''
    cd src
  '';

  preInstall = ''
    mkdir -p $out/lib/ladspa
  '';

  installFlags = [ "INSTALL_PLUGINS_DIR=${placeholder "out"}/lib/ladspa" ];

  meta = {
    description = "Computer Music Toolkit";
    homepage = "https://www.ladspa.org/cmt";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ sjfloat ];
    platforms = lib.platforms.linux;
  };
})
