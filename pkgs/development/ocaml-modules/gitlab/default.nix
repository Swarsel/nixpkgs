{
  lib,
  fetchFromGitHub,
  atdgen,
  atdgen-runtime,
  buildDunePackage,
  cohttp-lwt,
  iso8601,
  stringext,
  uri,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "gitlab";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "tmcgilchrist";
    repo = "ocaml-gitlab";
    rev = finalAttrs.version;
    hash = "sha256-7pUpH1SoP4eW8ild5j+Tcy+aTXq0+eSkhKUOXJ6Z30k=";
  };

  postPatch = ''
    substituteInPlace lib/dune --replace-warn 'atdgen str' 'atdgen-runtime str'
  '';

  nativeBuildInputs = [ atdgen ];
  buildInputs = [ stringext ];

  propagatedBuildInputs = [
    uri
    cohttp-lwt
    atdgen-runtime
    yojson
    iso8601
  ];

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Native OCaml bindings to Gitlab REST API v4";
    homepage = "https://github.com/tmcgilchrist/ocaml-gitlab";
    changelog = "https://github.com/tmcgilchrist/ocaml-gitlab/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zazedd ];
  };
})
