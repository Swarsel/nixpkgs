{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  nixosTests,
  nodejs,
  npmHooks,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "isso";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "isso-comments";
    repo = "isso";
    tag = finalAttrs.version;
    hash = "sha256-8kXqqiMXxF0wCJ+AzYT8j0rjuhlXO3F6UJbump672b4=";
  };

  outputs = [
    "out"
    "doc"
  ];

  postPatch = ''
    # Remove when https://github.com/isso-comments/isso/pull/973 is available.
    substituteInPlace isso/tests/test_comments.py \
      --replace "self.client.delete_cookie('localhost.local', '1')" "self.client.delete_cookie(key='1', domain='localhost')"
  '';

  nativeBuildInputs = [
    python3Packages.cffi
    python3Packages.sphinxHook
    python3Packages.sphinx
    nodejs
    npmHooks.npmConfigHook
  ];

  propagatedBuildInputs = with python3Packages; [
    itsdangerous
    jinja2
    misaka
    mistune
    html5lib
    werkzeug
    bleach
    flask-caching
  ];

  env.NODE_PATH = "$npmDeps";

  preBuild = ''
    ln -s ${finalAttrs.npmDeps}/node_modules ./node_modules
    export PATH="${finalAttrs.npmDeps}/bin:$PATH"

    make js
  '';

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    python3Packages.pytest-cov-stub
  ];

  format = "setuptools";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-e3r5iZLmXlf5YBPGgeNBDkdgfbNcIZIXbRLyyoyJiTU=";
  };

  passthru.tests = { inherit (nixosTests) isso; };

  meta = {
    description = "Commenting server similar to Disqus";
    homepage = "https://posativ.org/isso/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "isso";
  };
})
