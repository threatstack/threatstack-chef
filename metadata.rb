name             'threatstack'
maintainer       'Threat Stack'
maintainer_email 'support@threatstack.com'
license          'Apache 2.0'
description      'Installs/Configures Threat Stack cloudsight components'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.3.0'

supports 'amazon'
supports 'centos'
supports 'redhat'
supports 'ubuntu'

depends  'apt'
depends  'yum'
