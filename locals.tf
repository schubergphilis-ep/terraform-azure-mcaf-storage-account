locals {
  # The CMK identity must be attached to the storage account, so it is always included.
  user_assigned_identity_ids = distinct(concat(
    var.user_assigned_identities,
    var.cmk_key != null ? [var.cmk_key.user_assigned_identity_id] : []
  ))
}
