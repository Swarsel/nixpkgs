{
  buildDunePackage,
  containers,
  dune-configurator,
  gen,
  iter,
  mdx,
  ocaml,
  qcheck-core,
}:

buildDunePackage {
  inherit (containers) src version;
  pname = "containers-data";
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ containers ];
  doCheck = containers.doCheck && ocaml.meta.branch != "5.0";
  nativeCheckInputs = [ mdx.bin ];

  checkInputs = [
    gen
    iter
    qcheck-core
  ];

  meta = containers.meta // {
    description = "Set of advanced datatypes for containers";
  };
}
