{
  libmusicbrainz,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "libkcddb";
  extraBuildInputs = [ libmusicbrainz ];
}
