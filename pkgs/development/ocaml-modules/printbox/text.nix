{
  lib,
  buildDunePackage,
  mdx,
  ocaml,
  printbox,
  uucp,
  uutf,
}:

buildDunePackage {
  inherit (printbox) src version;
  pname = "printbox-text";

  propagatedBuildInputs = [
    printbox
    uucp
    uutf
  ];

  doCheck = printbox.doCheck && lib.versionOlder ocaml.version "5.0";
  nativeCheckInputs = [ mdx.bin ];

  meta = printbox.meta // {
    description = "Text renderer for printbox, using unicode edges";
  };
}
