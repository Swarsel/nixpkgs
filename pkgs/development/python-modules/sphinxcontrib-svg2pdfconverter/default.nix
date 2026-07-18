{
  lib,
  buildPythonPackage,
  cairosvg,
  fetchPypi,
  inkscape,
  librsvg,
  setuptools,
  sphinx,
  withCairosvg ? false,
  withInkscape ? false,
  withLibrsvg ? true,
}:

assert (withCairosvg || withInkscape || withLibrsvg);

buildPythonPackage rec {
  pname = "sphinxcontrib-svg2pdfconverter";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-q5yPEIA5HiMYEtIKvyZXpp7jVXRWOxAUQU+VOWSpX6M=";
    pname = "sphinxcontrib_svg2pdfconverter";
  };

  # for enabled modules: provide the full path to the binary
  postPatch =
    lib.optionalString withLibrsvg ''
      substituteInPlace sphinxcontrib/rsvgconverter.py \
        --replace-fail "'rsvg_converter_bin', 'rsvg-convert'" "'rsvg_converter_bin', '${lib.getExe' librsvg "rsvg-convert"}'"
    ''
    + lib.optionalString withInkscape ''
      substituteInPlace sphinxcontrib/inkscapeconverter.py \
        --replace-fail "'inkscape_converter_bin', 'inkscape'" "'inkscape_converter_bin', '${lib.getExe inkscape}'"
    '';

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ sphinx ] ++ lib.optional withCairosvg cairosvg;
  pyproject = true;

  pythonImportsCheck =
    lib.optional withCairosvg "sphinxcontrib.cairosvgconverter"
    ++ lib.optional withInkscape "sphinxcontrib.inkscapeconverter"
    ++ lib.optional withLibrsvg "sphinxcontrib.rsvgconverter";

  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx SVG to PDF converter extension";
    homepage = "https://github.com/missinglinkelectronics/sphinxcontrib-svg2pdfconverter";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dansbandit ];
  };
}
