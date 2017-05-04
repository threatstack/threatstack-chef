name             'threatstack'
maintainer       'Threat Stack'
maintainer_email 'support@threatstack.com'
license          'Apache 2.0'
description      'Installs/Configures Threat Stack cloudsight components'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.7.3'
issues_url       'https://github.com/threatstack/threatstack-chef/issues' if respond_to?(:issues_url)
source_url       'https://github.com/threatstack/threatstack-chef' if respond_to?(:source_url)

supports 'amazon'
supports 'centos'
supports 'redhat'
supports 'ubuntu'

depends  'apt'
depends  'yum'

chef_version '>= 11.0' if respond_to?(:chef_version)
