{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ppxlib,
  stdcompat,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_show";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "thierry-martinez";
    repo = "ppx_show";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-YwWAdOtb0zg2hqNkGRiigz/Pci8Jy/QD+WyUEohEsns=";
  };

  buildInputs = [
    stdcompat
    ppxlib
  ];

  meta = {
    description = "OCaml PPX deriver for deriving show based on ppxlib";
    homepage = "https://github.com/thierry-martinez/ppx_show";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ niols ];
  };
})
