{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  containers,
  iter,
  mdx,
}:

buildDunePackage (finalAttrs: {
  pname = "msat";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Gbury";
    repo = "mSAT";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ER7ZUejW+Zy3l2HIoFDYbR8iaKMvLZWaeWrOAAYXjG4=";
  };

  postPatch = ''
    substituteInPlace dune --replace mdx ocaml-mdx
  '';

  propagatedBuildInputs = [
    iter
  ];

  doCheck = true;
  nativeCheckInputs = [ mdx.bin ];
  checkInputs = [ containers ];

  meta = {
    description = "Modular sat/smt solver with proof output";
    homepage = "https://gbury.github.io/mSAT/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
