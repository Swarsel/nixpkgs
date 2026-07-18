{
  lib,
  fetchFromGitHub,
  base,
  buildDunePackage,
  nix-update-script,
  ppx_sexp_conv,
}:

buildDunePackage rec {
  pname = "tdigest";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "SGrondin";
    repo = pname;
    rev = version;
    sha256 = "sha256-faJ8ZQ7AWDHWfyQ2jq6+8TMe4G4NLjqHxYzLzt2LGh4=";
  };

  # base v0.17 compatibility
  patches = [ ./tdigest.patch ];

  propagatedBuildInputs = [
    base
    ppx_sexp_conv
  ];

  minimalOCamlVersion = "5.1";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OCaml implementation of the T-Digest algorithm";
    homepage = "https://github.com/SGrondin/${pname}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ niols ];
  };
}
