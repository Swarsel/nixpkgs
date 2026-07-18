{
  lib,
  fetchFromGitHub,
  python3Packages,
  voicevox-core,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "voicevox-engine";
  version = "0.25.2";

  src = fetchFromGitHub {
    owner = "VOICEVOX";
    repo = "voicevox_engine";
    tag = finalAttrs.version;
    hash = "sha256-A+ym/ZfHUHqXSGOiIndUeozrK64uJILCmRUm+qSsSNE=";
  };

  patches = [
    # this patch makes the package installable via hatchling
    ./make-installable.patch
  ];

  preConfigure = ''
    # copy demo metadata to temporary directory
    mv resources/character_info test_character_info

    # populate the `character_info` directory with the actual model metadata instead of the demo metadata
    cp -r --no-preserve=all ${finalAttrs.passthru.resources}/character_info resources/character_info

    # the `character_info` directory copied from `resources` doesn't exactly have the expected format,
    # so we transform them to be acceptable by `voicevox-engine`
    pushd resources/character_info
    for dir in *; do
        # remove unused large files
        rm $dir/*/*.png_large

        # rename directory from "$name_$uuid" to "$uuid"
        mv $dir ''${dir#*"_"}
    done
    popd
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    syrupy
    httpx
  ];

  preCheck = ''
    # some tests assume $HOME actually exists
    export HOME=$(mktemp -d)

    # since the actual metadata files have been installed to `$out` by this point,
    # we can move the demo metadata back to its place for the tests to succeed
    rm -r resources/character_info
    mv test_character_info resources/character_info
  '';

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = [
    finalAttrs.passthru.pyopenjtalk
  ]
  ++ (with python3Packages; [
    fastapi
    jinja2
    kanalizer
    numpy
    platformdirs
    psutil
    pydantic
    python-multipart
    pyworld
    pyyaml
    semver
    setuptools
    soundfile
    soxr
    starlette
    uvicorn
  ]);

  disabledTests = [
    # test expects an exact response, but OpenAPI is returning something a tiny bit different
    "test_OpenAPIの形が変わっていないことを確認"
  ];

  makeWrapperArgs = [
    ''--add-flags "--voicelib_dir=${voicevox-core.wrapped}/lib"''
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "psutil" # at the time of writing, psutil has not reached version 7.1.1
  ];

  pythonRemoveDeps = [
    # upstream wants fastapi-slim, but we provide fastapi instead
    "fastapi-slim"
  ];

  passthru = {
    pyopenjtalk = python3Packages.callPackage ./pyopenjtalk.nix { };

    resources = fetchFromGitHub {
      hash = "sha256-Byv9ASl1qCeGWJiBtpGoPFgpbwtSdn48XvzIDS0SHN4=";
      name = "voicevox-resource-${finalAttrs.version}"; # this contains ${version} to invalidate the hash upon updating the package
      owner = "VOICEVOX";
      repo = "voicevox_resource";
      tag = finalAttrs.version;
    };
  };

  meta = {
    description = "Engine for the VOICEVOX speech synthesis software";
    homepage = "https://github.com/VOICEVOX/voicevox_engine";
    changelog = "https://github.com/VOICEVOX/voicevox_engine/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      tomasajt
      eljamm
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "voicevox-engine";
  };
})
