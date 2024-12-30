Class DBSetup.Utils Extends %RegisteredObject
{
/// Change database permissions
/// <ul>
/// <li><var>dbDir</var> Path to the database.</li>
/// <li><var>mode</var> Permission mode. 0 = read/write, 1 = read-only. Optional</li>
/// </ul>
ClassMethod SetupDBPermissions(dbDir as %String, mode as %Integer = 0) As %Status {
  New $NAMESPACE
  Set $NAMESPACE = "%SYS"

  Set sc = $$$OK

  Set db = ##class(SYS.Database).%OpenId(dbDir)
  Write "Setting database permission for " _ db.Directory _ ". Setting ReadOnly from " _ db.ReadOnly _ " to " _ mode, !
  Set db.ReadOnly = mode
  $$$ThrowOnError(db.%Save())

  Return sc
}
}