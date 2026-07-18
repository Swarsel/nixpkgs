{
  lib,
  fetchFromGitLab,
  base64,
  buildDunePackage,
  cudf,
  extlib,
  ocaml,
  ocamlgraph,
  ounit,
  parmap,
  re,
  stdlib-shims,
}:

buildDunePackage (finalAttrs: {
  pname = "dose3";
  version = "7.0.0";

  src = fetchFromGitLab {
    owner = "irill";
    repo = "dose3";
    rev = finalAttrs.version;
    hash = "sha256-K0fYSAWV48Rers/foDrEIqieyJ0PvpXkuYrFrZGBkkE=";
  };

  buildInputs = [
    parmap
  ];

  propagatedBuildInputs = [
    base64
    cudf
    extlib
    ocamlgraph
    re
    stdlib-shims
  ];

  # Check are not compatible with re ≥ 1.12
  doCheck = lib.versionAtLeast ocaml.version "4.08" && !lib.versionAtLeast ocaml.version "4.12";

  checkInputs = [
    ounit
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Dose library (part of Mancoosi tools)";

    longDescription = ''
      The dose suite provides libraries for handling package meta-data, and various tools for analyzing package relationships in a large package repository.
      * dose-builddebcheck checks, given a collection of source package stanzas and a collection of binary package stanzas of Debian packages, whether the build-dependencies of each source package can be satisfied by the binary packages.
      * dose-distcheck checks for every package of a distribution whether it is possible to satisfy its dependencies and conflicts within this distribution.
      * ceve, a general metadata parser supporting different input formats (Debian, rpm, and others) and different output formats.
      * dose-outdated, a Debian-specific tool for finding packages that are not installable with respect to a package repository, and that can only be made installable again by fixing the package itself.
      * dose-challenged, a Debian-specific tool for checking which packages will certainly become uninstallable when some existing package is upgraded to a newer version.
      * dose-deb-coinstall, a Debian-specific tool for checking whether a set of packages can be installed all together.
    '';

    homepage = "https://www.mancoosi.org/software/";
    license = lib.licenses.lgpl3Plus;
    downloadPage = "https://gitlab.com/irill/dose3/";
  };
})
