{
  lib,
  fetchFromGitHub,
  alcotest,
  angstrom,
  buildDunePackage,
  faraday,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "httpaf";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "inhabitedtype";
    repo = "httpaf";
    rev = finalAttrs.version;
    sha256 = "0zk78af3qyvf6w66mg8sxygr6ndayzqw5s3zfxibvn121xwni26z";
  };

  propagatedBuildInputs = [
    angstrom
    faraday
    result
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.08";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "High-performance, memory-efficient, and scalable web server for OCaml";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
