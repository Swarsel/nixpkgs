{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "reactivex";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "ReactiveX";
    repo = "RxPY";
    tag = "v${version}";
    hash = "sha256-napPfp72gqy43UmkPu1/erhjmJbZypHZQikmjIFVBqA=";
  };

  patches = [
    # Upstream PR: https://github.com/ReactiveX/RxPY/pull/728
    (fetchpatch {
      hash = "sha256-1GQm/4BTd5ZnIqfEUSb0Ja3w0y1R9EoFpzwua7gpIzo=";
      name = "python-3.14.patch";
      url = "https://github.com/ReactiveX/RxPY/commit/78f4a594ca2b0e27ad93ec0e1b1c0d56d5d6540d.patch";
    })
  ];

  postPatch = ''
    # Upstream doesn't set a version for their GitHub releases
    substituteInPlace pyproject.toml \
      --replace 'version = "0.0.0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "reactivex" ];

  meta = {
    description = "Library for composing asynchronous and event-based programs";
    homepage = "https://github.com/ReactiveX/RxPY";
    changelog = "https://github.com/ReactiveX/RxPY/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
