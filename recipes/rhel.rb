yum_repository 'threatstack' do
  description 'Threat Stack'
  baseurl node['threatstack']['repo']['url']
  gpgkey node['threatstack']['repo']['key']
  action :add
end
