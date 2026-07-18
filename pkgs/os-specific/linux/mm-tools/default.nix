{
  stdenv,
  linux,
}:

stdenv.mkDerivation {
  inherit (linux) version src;
  pname = "mm-tools";
  makeFlags = [ "sbindir=${placeholder "out"}/bin" ];
  preConfigure = "cd tools/mm";

  meta = {
    inherit (linux.meta) license platforms;
    description = "Set of virtual memory tools";
    maintainers = [ ];
  };
}
