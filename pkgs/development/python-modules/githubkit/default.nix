{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  hishel,
  httpx,
  pydantic,
  pyjwt,
  pytest-cov-stub,
  pytestCheckHook,
  typing-extensions,
  uv-build,
}:

let

  mkGithubkitSchema =
    {
      pname,
      src,
      version,
    }:
    buildPythonPackage {
      inherit pname version src;
      build-system = [ uv-build ];
      pyproject = true;

      # circular dependencies
      pythonRemoveDeps = [
        "githubkit"
        "githubkit-schemas"
      ];

      sourceRoot = "${src.name}/packages/${pname}";
    };

in

buildPythonPackage (finalAttrs: {
  pname = "githubkit";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "yanyongyu";
    repo = "githubkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zVUJWwmRx/2phkDWwWyazhPdwthsMMcE0S7E4R1TebQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ uv-build ];

  dependencies = [
    anyio
    httpx
    hishel
    typing-extensions
    pydantic
  ]
  ++ hishel.optional-dependencies.async
  ++ hishel.optional-dependencies.httpx
  # for simplicity we just propagate all schemas, rather than litter pkgs/development/python-modules
  ++ lib.attrValues finalAttrs.passthru.schemas;

  disabledTests = [
    # Tests require network access
    "test_graphql"
    "test_async_graphql"
    "test_call"
    "test_async_call"
    "test_versioned_call"
    "test_versioned_async_call"
  ];

  optional-dependencies = {
    all = [ pyjwt ];
    auth = [ pyjwt ];
    auth-app = [ pyjwt ];
    auth-oauth-device = [ ];
    jwt = [ pyjwt ];
  };

  pyproject = true;
  pythonImportsCheck = [ "githubkit" ];

  passthru.schemas = {
    githubkit-schemas = mkGithubkitSchema {
      inherit (finalAttrs) src;
      pname = "githubkit-schemas";
      version = "26.6.14";
    };

    githubkit-schemas-2022-11-28 = mkGithubkitSchema {
      inherit (finalAttrs) src;
      pname = "githubkit-schemas-2022-11-28";
      version = "26.6.14";
    };

    githubkit-schemas-2026-03-10 = mkGithubkitSchema {
      inherit (finalAttrs) src;
      pname = "githubkit-schemas-2026-03-10";
      version = "26.6.14";
    };

    githubkit-schemas-ghec-2022-11-28 = mkGithubkitSchema {
      inherit (finalAttrs) src;
      pname = "githubkit-schemas-ghec-2022-11-28";
      version = "26.6.14";
    };

    githubkit-schemas-ghec-2026-03-10 = mkGithubkitSchema {
      inherit (finalAttrs) src;
      pname = "githubkit-schemas-ghec-2026-03-10";
      version = "26.6.14";
    };
  };

  meta = {
    description = "GitHub SDK for Python";
    homepage = "https://github.com/yanyongyu/githubkit";
    changelog = "https://github.com/yanyongyu/githubkit/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
