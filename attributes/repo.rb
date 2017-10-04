default['threatstack']['repo_enable'] = true
default['threatstack']['repo']['components'] = ['main']

case node['platform_family']
when 'debian'
  if node['platform'] == 'debian'
    default['threatstack']['repo']['dist'] = 'wheezy'
  else
    default['threatstack']['repo']['dist'] = node['lsb']['codename']
  end
  default['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/Ubuntu'
  default['threatstack']['repo']['key'] = 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
when 'rhel', 'fedora', 'amazon'
  case node['platform']
  when 'amazon'
    default['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/Amazon'
  when 'centos', 'redhat'
    default['threatstack']['repo']['url'] = "https://pkg.threatstack.com/EL/#{node['platform_version'].to_i}"
  else
    default['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/EL/7'
  end
  default['threatstack']['repo']['key'] = 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
  default['threatstack']['repo']['key_file'] = '/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
  default['threatstack']['repo']['key_file_uri'] = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
end
