{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "makejinja";
  version = "2.8.2";

  src = fetchFromGitHub {
    owner = "mirkolenz";
    repo = "makejinja";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TH4pgohh6yIgsPtsHnYSUr17Apk8C02KD+8sNO5GOf8=";
  };

  nativeCheckInputs = with python3Packages; [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = with python3Packages; [ uv-build ];

  dependencies =
    with python3Packages;
    [
      frozendict
      jinja2
      pyyaml
      rich-click
      typed-settings
    ]
    ++ typed-settings.optional-dependencies.attrs
    ++ typed-settings.optional-dependencies.cattrs
    ++ typed-settings.optional-dependencies.click;

  pyproject = true;

  meta = {
    description = "Generate entire directory structures using Jinja templates with support for external data and custom plugins";
    homepage = "https://github.com/mirkolenz/makejinja";
    changelog = "https://github.com/mirkolenz/makejinja/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tomasajt
      mirkolenz
    ];

    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "makejinja";
  };
})
