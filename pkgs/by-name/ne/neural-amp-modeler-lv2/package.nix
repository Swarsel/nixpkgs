{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    tag = finalAttrs.version;
    hash = "sha256-5BOZOocZWWSWawXJFMAgM0NR0s0CbkzDVr6fnvZMvd0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "Neural Amp Modeler LV2 plugin implementation";
    homepage = finalAttrs.src.meta.homepage;
    license = [ lib.licenses.gpl3 ];
    maintainers = [ lib.maintainers.viraptor ];
  };
})
