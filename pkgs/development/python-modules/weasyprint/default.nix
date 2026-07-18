{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cffi,
  cssselect2,
  fetchpatch2,
  # build-system
  flit-core,
  fontconfig,
  fonttools,
  glib,
  harfbuzz,
  makeFontsConf,
  pango,
  pillow,
  pkgs,
  pydyf,
  pyphen,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  replaceVars,
  tinycss2,
  tinyhtml5,
  twemoji-color-font,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "weasyprint";
  version = "69.0";

  src = fetchFromGitHub {
    owner = "Kozea";
    repo = "WeasyPrint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kd5ei3dBty8VL0ATPz8LZFP+UTUq7yTjuDtO1s/fdxg=";
  };

  patches = [
    (replaceVars ./library-paths.patch {
      fontconfig = "${fontconfig.lib}/lib/libfontconfig${stdenv.hostPlatform.extensions.sharedLibrary}";
      gobject = "${glib.out}/lib/libgobject-2.0${stdenv.hostPlatform.extensions.sharedLibrary}";
      harfbuzz = "${harfbuzz.out}/lib/libharfbuzz${stdenv.hostPlatform.extensions.sharedLibrary}";
      harfbuzz_subset = "${harfbuzz.out}/lib/libharfbuzz-subset${stdenv.hostPlatform.extensions.sharedLibrary}";
      pango = "${pango.out}/lib/libpango-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
      pangoft2 = "${pango.out}/lib/libpangoft2-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    (fetchpatch2 {
      hash = "sha256-uixfpg9fvkdNmSTqz/M1c1vkV/mJDqOs7zDAunn2rEY=";
      name = "fix-unicode-test";
      url = "https://github.com/Kozea/WeasyPrint/commit/b2efb459fbe7f7fd35ab9078734121cb87d3d65a.patch?full_index=1";
    })
  ];

  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";

  nativeCheckInputs = [
    pkgs.ghostscript
    pytest-cov-stub
    pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  # Custom font configuration for tests
  preCheck = ''
    export FONTCONFIG_FILE=${
      makeFontsConf {
        # include some emoji characters
        fontDirectories = [ twemoji-color-font ];
        # Darwin builds without sandbox can pollute the build
        impureFontDirectories = [ ];
      }
    }
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ flit-core ];

  dependencies = [
    cffi
    cssselect2
    fonttools
    pillow
    pydyf
    pyphen
    tinycss2
    tinyhtml5
  ]
  ++ fonttools.optional-dependencies.woff;

  disabledTests = [
    # needs the Ahem font (fails on macOS)
    "test_font_stretch"
    # sensitive to sandbox environments
    "test_linear_gradients_12"
    "test_linear_gradients_5"
    "test_tab_size"
    "test_tabulation_character"
    # rounding issues in sandbox
    "test_empty_inline_auto_margins"
    "test_images_transparent_text"
    "test_layout_table_auto_44"
    "test_layout_table_auto_45"
    "test_margin_boxes_element"
    "test_running_elements"
    "test_vertical_align_4"
    "test_visibility_1"
    "test_visibility_3"
    "test_visibility_4"
    "test_woff_simple"
    # AssertionError
    "test_2d_transform"
  ];

  # Set env variable explicitly for Darwin, but allow overriding when invoking directly
  makeWrapperArgs = [ "--set-default FONTCONFIG_FILE ${finalAttrs.env.FONTCONFIG_FILE}" ];
  pyproject = true;
  pythonImportsCheck = [ "weasyprint" ];

  meta = {
    description = "Converts web documents to PDF";
    homepage = "https://weasyprint.org/";
    changelog = "https://github.com/Kozea/WeasyPrint/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      DutchGerman
      friedow
    ];

    mainProgram = "weasyprint";
  };
})
