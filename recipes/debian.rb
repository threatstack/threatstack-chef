package 'apt-transport-https'

apt_repository 'threatstack' do
  uri node['threatstack']['repo']['url']
  distribution node['threatstack']['repo']['dist']
  components ['main']
  key node['threatstack']['repo']['key']
  action :add
end
