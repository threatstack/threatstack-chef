# Cookbook Name:: threatstack
# Library:: recipe_helpers

# module ThreatstackHelper contains threatstack recipe helpers
module ThreatstackHelper
  # top level method called by the recipe to find the deploy_key
  def get_deploy_key(node)
    find_my_attribute(node, 'deploy_key')
  end

  # Generate the cloudsight command string(s) required to configure the agent
  def gen_cmd(node, agent_config_args_full)
    cmd = ''
    deploy_key = get_deploy_key(node)
    unless agent_config_args_full.empty?
      agent_config_args_full.each do |arg|
        cmd += "cloudsight config #{arg} ;"
      end
    end
    cmd += "cloudsight setup --deploy-key=#{deploy_key}"
    cmd += " --hostname='#{node['threatstack']['hostname']}'" if node['threatstack']['hostname']
    cmd += " #{node['threatstack']['agent_extra_args']}" if node['threatstack']['agent_extra_args'] != ''
    unless node['threatstack']['rulesets'].empty?
      node['threatstack']['rulesets'].each do |r|
        cmd += " --ruleset='#{r}'"
      end
    end
    cmd
  end

  private

  # Resuable find attribute method where run_state, normal attributes, and data_bags are looked through to find the value.
  def find_my_attribute(node, attribute)
    if node.run_state.key?('threatstack') && node.run_state['threatstack'].key?(attribute)
      node.run_state['threatstack'][attribute]
    elsif node['threatstack'].key?(attribute) && node['threatstack'][attribute]
      node['threatstack'][attribute]
    else
      begin
        data_bag_item(node['threatstack']['data_bag_name'], node['threatstack']['data_bag_item'])[attribute]
      rescue
        nil
      end
    end
  end
end

Chef::Recipe.send(:include, ThreatstackHelper)
Chef::Resource.send(:include, ThreatstackHelper)
Chef::Provider.send(:include, ThreatstackHelper)
