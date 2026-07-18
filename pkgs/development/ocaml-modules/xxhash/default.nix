{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ctypes,
  ctypes-foreign,
  dune-configurator,
  pkgs,
  ppx_expect,
}:

buildDunePackage rec {
  pname = "xxhash";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "314eter";
    repo = "ocaml-xxhash";
    tag = "v${version}";
    hash = "sha256-0+ac5EWV9DCVMT4wOcXC95GVEwsUIZzFn2laSzmK6jE=";
  };

  postPatch = ''
    substituteInPlace stubs/dune --replace-warn 'ctypes))' 'ctypes ctypes.stubs))'
  '';

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    ctypes
    ctypes-foreign
    pkgs.xxhash
  ];

  doCheck = true;

  checkInputs = [
    ppx_expect
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Bindings for xxHash, an extremely fast hash algorithm";
    homepage = "https://github.com/314eter/ocaml-xxhash";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ toastal ];
  };
}
