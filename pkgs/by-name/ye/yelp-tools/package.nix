{
  lib,
  fetchurl,
  gnome,
  itstool,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  python3,
  yelp-xsl,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "yelp-tools";
  version = "42.1";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp-tools/${lib.versions.major version}/yelp-tools-${version}.tar.xz";
    sha256 = "PklqQCDUFFuZ/VCKJfoJM2pQOk6JAAKEIecsaksR+QU=";
  };

  strictDeps = false; # TODO: Meson cannot find xmllint oherwise. Maybe add it to machine file?

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    itstool # build script checks for its presence but I am not sure if anything uses it
    yelp-xsl
  ];

  propagatedBuildInputs = [
    libxml2 # xmllint required by yelp-check.
    libxslt # xsltproc required by yelp-build and yelp-check.
  ];

  doCheck = true;
  pyproject = false;

  pythonPath = [
    python3.pkgs.lxml
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "Small programs that help you create, edit, manage, and publish your Mallard or DocBook documentation";
    homepage = "https://gitlab.gnome.org/GNOME/yelp-tools";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
