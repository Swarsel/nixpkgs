{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  re,
}:

buildDunePackage (finalAttrs: {
  pname = "duppy";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-duppy";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-hWR7utYMxMjz8Cw0j6cgoHlUj4Jc7Q4vJHD5kGHN4Rc=";
  };

  propagatedBuildInputs = [ re ];
  minimalOCamlVersion = "4.07";

  meta = {
    description = "Library providing monadic threads";
    homepage = "https://github.com/savonet/ocaml-duppy";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
