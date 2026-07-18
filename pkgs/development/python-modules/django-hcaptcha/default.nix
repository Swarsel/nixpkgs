{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-hcaptcha";
  version = "0.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-slGerwzJeGWscvglMBEixc9h4eSFLWiVmUFgIirLbBo=";
    pname = "django-hCaptcha";
  };

  propagatedBuildInputs = [ django ];
  # No tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "hcaptcha" ];

  meta = {
    description = "Django hCaptcha provides a simple way to protect your django forms using hCaptcha";
    homepage = "https://github.com/AndrejZbin/django-hcaptcha";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
