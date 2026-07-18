{
  include,
  mkDerivation,
}:

mkDerivation {
  buildInputs = [
    include
  ];

  alwaysKeepStatic = true;
  noLibc = true;
  path = "lib/libssp_nonshared";
}
