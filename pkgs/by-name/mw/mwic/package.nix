{
  lib,
  stdenv,
  fetchurl,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mwic";
  version = "0.7.10";

  src = fetchurl {
    url = "https://github.com/jwilk/mwic/releases/download/${finalAttrs.version}/mwic-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-dmIHPehkxpSb78ymVpcPCu4L41coskrHQOg067dprOo=";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
  ];

  propagatedBuildInputs = with python3Packages; [
    pyenchant
    regex
  ];

  makeFlags = [ "PREFIX=\${out}" ];

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = {
    description = "Spell-checker that groups possible misspellings and shows them in their contexts";
    homepage = "http://jwilk.net/software/mwic";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "mwic";
  };
})
