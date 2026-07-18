{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  cctools,
  fetchpatch,
  nix-update-script,
  nodejs_22,
  python3Minimal,
  stdenvNoCC,
}:

buildNpmPackage (finalAttrs: {
  pname = "dl-librescore";
  version = "0.35.40";

  src = fetchFromGitHub {
    owner = "LibreScore";
    repo = "dl-librescore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jCwySndc3ZeEoKVA9Ne2PLStyM73hDPO1vaNeVShwQ0=";
  };

  patches = [
    # https://github.com/LibreScore/dl-librescore/pull/144
    (fetchpatch {
      hash = "sha256-ikEJNwKMDWpWBQnS3ur76vZqF+zRI6D5d0AyLDdreJY=";
      name = "update-pdfkit.patch";
      url = "https://github.com/LibreScore/dl-librescore/commit/3694697d2d3f3f59ca32ee962999b3dd22c81de7.patch";
    })
  ];

  postPatch = ''
    for file in src/i18n/*.json; do
      substituteInPlace "$file" --replace-quiet \
        'Run npm i -g dl-librescore@{{latest}} to update' ""
    done
  '';

  nativeBuildInputs = [
    python3Minimal
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [ cctools ];

  npmDepsHash = "sha256-8x1WuzIaxzaEgM9hu2cCtXr4GLCE6DHt3F7lvnbcMgk=";
  makeCacheWritable = true;
  nodejs = nodejs_22;
  npmDepsFetcherVersion = 2;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Download sheet music";
    homepage = "https://github.com/LibreScore/dl-librescore";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "dl-librescore";
  };
})
