{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "collapseos-cvm";
  version = "20220316";

  src = fetchurl {
    url = "https://collapseos.org/files/collapseos-${finalAttrs.version}.tar.gz";
    hash = "sha256-8bt6wj93T82K9fqtuC/mctkMCzfvW0taxv6QAKeJb5g=";
  };

  postPatch = ''
    substituteInPlace common.mk \
      --replace "-lcurses" "-lncurses"
  '';

  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall;
    find . -type f -executable -exec install -Dt $out/bin {} \;
    runHook postInstall;
  '';

  sourceRoot = "cvm";

  meta = {
    description = "Virtual machine for Collapse OS (Forth operating system)";
    homepage = "http://collapseos.org/";
    changelog = "http://collapseos.org/files/CHANGES.txt";
    license = lib.licenses.gpl3Only;
    mainProgram = "cos-serial";
    downloadPage = "http://collapseos.org/files/";
  };
})
