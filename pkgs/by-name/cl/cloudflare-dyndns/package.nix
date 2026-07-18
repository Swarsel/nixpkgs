{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cloudflare-dyndns";
  version = "5.4";

  src = fetchFromGitHub {
    owner = "kissgyorgy";
    repo = "cloudflare-dyndns";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tCZX9CKDwGAZ8/rwI764uuE9SQ1A5WhVoqgUegJ19g4=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    hatchling
  ];

  dependencies = with python3.pkgs; [
    click
    httpx
    pydantic
    truststore
  ];

  disabledTests = [
    "test_get_ipv4"
  ];

  pyproject = true;

  meta = {
    description = "CloudFlare Dynamic DNS client";
    homepage = "https://github.com/kissgyorgy/cloudflare-dyndns";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
    mainProgram = "cloudflare-dyndns";
  };
})
