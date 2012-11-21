# Puppet sxid module

Module for configuring [sXid](http://linukz.org/sxid.shtml)

sXid tracks any changes in your s[ug]id files and folders.

Tested on Debian GNU/Linux 6.0 Squeeze.

Patches for other operating systems welcome.

## Example

```puppet
class { 'sxid':
  email         => 'admin@domain.tld',
  always_notify => 'yes',
  keep_logs     => 10,
  exclude       => ['/proc', '/mnt', '/cdrom', '/floppy'],
  forbidden     => ['/home', '/tmp'],
}
```