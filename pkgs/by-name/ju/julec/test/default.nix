{
  clangStdenv,
  julec,
}:

clangStdenv.mkDerivation (finalAttrs: {
  inherit (julec) version;
  pname = "hello-jule";
  src = ./hello-jule;
  nativeBuildInputs = [ julec.hook ];
  doCheck = true;

  meta = {
    inherit (julec.meta) platforms;
  };
})
