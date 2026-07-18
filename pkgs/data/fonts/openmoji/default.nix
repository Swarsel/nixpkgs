{
  lib,
  fetchFromGitHub,
  nanoemoji,
  python3Packages,
  stdenvNoCC,
  woff2,
  xmlstarlet,
  # when at least one of the glyf_colr_0/1 formats is specified, whether to build maximum color fonts
  # "none" to not build any, "svg" to build colr+svg, "bitmap" to build cbdt+colr+svg fonts
  buildMaximumColorFonts ? "bitmap",
  # available color formats: ["cbdt" "glyf_colr_0" "glyf_colr_1" "sbix" "picosvgz" "untouchedsvgz"]
  # available black formats: ["glyf"]
  fontFormats ? [
    "glyf"
    "cbdt"
    "glyf_colr_0"
    "glyf_colr_1"
  ],
}:
let
  # all available methods
  methods = {
    black = [ "glyf" ];

    color = [
      "cbdt"
      "glyf_colr_0"
      "glyf_colr_1"
      "sbix"
      "picosvgz"
      "untouchedsvgz"
    ];
  };
in

assert lib.asserts.assertEachOneOf "fontFormats" fontFormats (methods.black ++ methods.color);
assert lib.asserts.assertOneOf "buildMaximumColorFonts" buildMaximumColorFonts [
  "none"
  "bitmap"
  "svg"
];

stdenvNoCC.mkDerivation rec {
  pname = "openmoji";
  version = "17.0.0";

  src = fetchFromGitHub {
    owner = "hfg-gmuend";
    repo = "openmoji";
    rev = version;
    hash = "sha256-mE34l94C/jc7Fd4v7opMeneFZAou5w9KhjLSVxw0s/0=";
  };

  patches = [
    # fix paths and variables for nix build and skip generating font demos
    ./build.patch
  ];

  postPatch = lib.optionalString (buildMaximumColorFonts == "bitmap") ''
    substituteInPlace helpers/generate-fonts-runner.sh \
      --replace 'maximum_color' 'maximum_color --bitmaps'
  '';

  nativeBuildInputs = [
    nanoemoji
    python3Packages.fonttools
    woff2
    xmlstarlet
  ];

  buildPhase = ''
    runHook preBuild

    bash helpers/generate-fonts-runner.sh "$(pwd)/build" "${version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype $out/share/fonts/woff2
    cp build/fonts/*/*.ttf $out/share/fonts/truetype/
    cp build/fonts/*/*.woff2 $out/share/fonts/woff2/

    runHook postInstall
  '';

  maximumColorVersions = lib.optionals (buildMaximumColorFonts != "none") (
    lib.optional (builtins.elem "glyf_colr_0" fontFormats) "0"
    ++ lib.optional (builtins.elem "glyf_colr_1" fontFormats) "1"
  );

  methods_black = builtins.filter (m: builtins.elem m fontFormats) methods.black;
  methods_color = builtins.filter (m: builtins.elem m fontFormats) methods.color;

  saturations =
    lib.optional (methods_black != [ ]) "black" ++ lib.optional (methods_color != [ ]) "color";

  meta = {
    description = "Open-source emojis for designers, developers and everyone else";
    homepage = "https://openmoji.org/";
    license = lib.licenses.cc-by-sa-40;

    maintainers = with lib.maintainers; [
      _999eagle
      fgaz
    ];

    platforms = lib.platforms.all;
    downloadPage = "https://github.com/hfg-gmuend/openmoji/releases";
  };
}
