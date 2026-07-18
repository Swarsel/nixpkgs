{
  tpm2-pkcs11,
  ...
}@args:

tpm2-pkcs11.override (
  args
  // {
    extraDescription = "Disables FAPI support, as if TPM2_PKCS11_BACKEND were always set to 'esysdb'.";
    fapiSupport = false;
  }
)
