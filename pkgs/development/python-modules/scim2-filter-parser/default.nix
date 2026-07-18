{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  fetchpatch,
  mock,
  poetry-core,
  pytestCheckHook,
  sly,
}:

buildPythonPackage rec {
  pname = "scim2-filter-parser";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "15five";
    repo = "scim2-filter-parser";
    tag = version;
    hash = "sha256-KmtOtI/5HT0lVwvXQFTlEwMeptoa4cA5hTSgSULxhIc=";
  };

  patches = [
    # https://github.com/15five/scim2-filter-parser/pull/43
    (fetchpatch {
      hash = "sha256-PjJH1S5CDe/BMI0+mB34KdpNNcHfexBFYBmHolsWH4o=";
      name = "replace-poetry-with-poetry-core.patch";
      url = "https://github.com/15five/scim2-filter-parser/commit/675d85f3a3ff338e96a408827d64d9e893fa5255.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry.masonry.api" "poetry.core.masonry.api"
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.django-query;

  build-system = [ poetry-core ];
  dependencies = [ sly ];

  optional-dependencies = {
    django-query = [ django ];
  };

  pyproject = true;
  pythonImportsCheck = [ "scim2_filter_parser" ];

  meta = {
    description = "Customizable parser/transpiler for SCIM2.0 filters";
    homepage = "https://github.com/15five/scim2-filter-parser";
    changelog = "https://github.com/15five/scim2-filter-parser/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ s1341 ];
  };
}
