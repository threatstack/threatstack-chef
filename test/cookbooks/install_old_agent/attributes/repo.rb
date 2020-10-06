default['threatstack']['repo_enable'] = true
default['threatstack']['old_agent']['validate_gpg_key'] = true
default['threatstack']['old_agent']['repo']['components'] = ['main']

case node['platform_family']
when 'debian'
  default['threatstack']['old_agent']['repo']['dist'] = node['lsb']['codename']
  default['threatstack']['old_agent']['repo']['url'] = 'https://pkg.threatstack.com/v2/Ubuntu'
  default['threatstack']['old_agent']['repo']['key'] = 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
when 'rhel', 'fedora', 'amazon'
  case node['platform']
  when 'amazon'
    if node['platform_version'] == '2'
      default['threatstack']['old_agent']['repo']['url'] = 'https://pkg.threatstack.com/v2/Amazon/2'
    else
      default['threatstack']['old_agent']['repo']['url'] = 'https://pkg.threatstack.com/v2/Amazon/1'
    end
  when 'centos', 'redhat'
    default['threatstack']['old_agent']['repo']['url'] = "https://pkg.threatstack.com/v2/EL/#{node['platform_version'].to_i}"
  else
    default['threatstack']['old_agent']['repo']['url'] = 'https://pkg.threatstack.com/v2/EL/7'
  end
  default['threatstack']['old_agent']['repo']['key'] = 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
  default['threatstack']['old_agent']['repo']['key_file'] = '/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
  default['threatstack']['old_agent']['repo']['key_file_uri'] = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
end
