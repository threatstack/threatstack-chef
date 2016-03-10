default['threatstack']['repo_enable'] = true

case node['platform_family']
when 'debian'
  default['threatstack']['repo']['dist'] = if node['platform'] == 'debian'
                                             'wheezy'
                                           else
                                             node['lsb']['codename']
                                           end
  default['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/Ubuntu'
  default['threatstack']['repo']['key'] = 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
when 'rhel'
  default['threatstack']['repo']['url'] = if node['platform'] == 'amazon'
                                            'https://pkg.threatstack.com/Amazon'
                                          else
                                            'https://pkg.threatstack.com/CentOS'
                                          end
  default['threatstack']['repo']['key'] = 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
end
