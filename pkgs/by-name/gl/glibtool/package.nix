{ libtool }:

libtool.overrideAttrs {
  pname = "glibtool";
  configureFlags = [ "--program-prefix=g" ];
  meta.mainProgram = "glibtool";
}
