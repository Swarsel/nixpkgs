{
  lib,
  fetchzip,
}:
fetchzip (finalAttrs: {
  pname = "twitter-bootstrap";
  version = "5.3.8";
  hash = "sha256-StRhHJIRGzguLlo0BGOAMy0PCCmMovzgU/5xZJgVrqQ=";
  url = "https://github.com/twbs/bootstrap/releases/download/v${finalAttrs.version}/bootstrap-${finalAttrs.version}-dist.zip";

  meta = {
    description = "Front-end framework for faster and easier web development";
    homepage = "https://getbootstrap.com/";
    license = lib.licenses.mit;
  };
})
