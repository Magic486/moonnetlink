///|
test "real Linux controller capture completes typed metadata and ACK" {
  let records = @journal.parse(@fixtures.family_journal_text())
  let transaction = @genl.Lookup::new(1U, "nlctrl")
  for record in records {
    guard record is @journal.Datagram(data, endian) else {
      fail("expected datagram")
    }
    for message in @wire.decode(data, endian~) {
      if transaction.status() == @genl.Pending {
        ignore(transaction.accept(message, endian~))
      }
    }
  }
  let family = transaction.result()
  assert_eq(family.id, 16)
  assert_eq(family.name, "nlctrl")
  assert_eq(family.version, Some(2U))
  assert_true(family.operations.length() > 0)
  assert_true(family.groups.any(group => group.name == "notify"))
}
