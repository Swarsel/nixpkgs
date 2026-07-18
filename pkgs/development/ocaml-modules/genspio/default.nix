{
  lib,
  fetchFromGitHub,
  base,
  buildDunePackage,
  fmt,
}:

buildDunePackage (finalAttrs: {
  pname = "genspio";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "hammerlab";
    repo = "genspio";
    rev = "genspio.${finalAttrs.version}";
    sha256 = "sha256:1788cnn10idp5i1hggg4pys7k0w8m3h2p4xa42jipfg4cpj7shaf";
  };

  # base v0.17 compatibility
  patches = [ ./genspio.patch ];

  propagatedBuildInputs = [
    base
    fmt
  ];

  doCheck = true;
  duneVersion = "3";

  meta = {
    description = "Typed EDSL to generate POSIX Shell scripts";
    homepage = "https://smondet.gitlab.io/genspio-doc/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
